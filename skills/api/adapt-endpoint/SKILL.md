---
name: adapt-endpoint
description: Adapt a metavix-api backend endpoint to the frontend — generates types, API client function, and TanStack Query hook ready to use in components.
---

# adapt-endpoint

Adapts a `metavix-api` endpoint to the metavix-app frontend. Generates three files (or appends to existing ones):
1. **Types** — request/response TypeScript interfaces
2. **API client function** — typed fetch wrapper in `src/lib/api/`
3. **TanStack Query hook** — `useQuery` for GET, `useMutation` for POST/PUT/PATCH/DELETE

## Input resolution (hybrid)

**If `$ARGUMENTS` is provided**, parse it directly. Expected format:
```
METHOD /path [brief description]
```
Examples:
```
GET /patients/{id}/daily-records
POST /patients/{id}/daily-records Creates a new DailyRecord for the patient
DELETE /link-requests/{id}
```

**If `$ARGUMENTS` is empty**, do the following:
1. Read `/Users/orla/dev/metavix/docs/API.md`
2. List all available endpoints grouped by resource (e.g., Auth, Patient, Doctor, LinkRequest)
3. Ask: "Which endpoint do you want to adapt?" — wait for the user to pick one before proceeding
4. Use the selected endpoint as input

---

## Step 1 — Resolve endpoint details

From the parsed or selected endpoint, determine:
- **HTTP method**: GET, POST, PUT, PATCH, or DELETE
- **Path**: exact path with `{param}` placeholders
- **Path params**: any `{param}` in the path → required arguments to the client function
- **Request body**: for POST/PUT/PATCH — infer fields from API.md or ask the user if not documented
- **Response shape**: infer from API.md or ask the user if not documented
- **Resource name**: the primary domain entity (e.g., `daily-records`, `lab-records`, `link-requests`, `patients`, `doctors`)

If anything is ambiguous, STOP and ask ONE focused question. Never infer fields that aren't documented.

---

## Step 2 — Check for known API gaps

Before generating anything, verify the endpoint doesn't belong to the known pending list:
- `glucosas_comidas` / `GlucosaReading` array on `DailyRecord` — **no endpoint exists yet**
- `embarazada` / `ClinicalFlags` — **no endpoint exists yet**

If the requested endpoint involves these fields, warn the user:
> "This field is documented as a known API gap in `.agents/CONTEXT.md` — the endpoint hasn't been built in `metavix-api` yet. Do you want to generate the frontend layer anyway (with a disabled submission gate), or skip for now?"

Wait for confirmation before proceeding.

---

## Step 3 — Generate TypeScript types

**Location:** `src/types/{resource}.ts`
- If the file already exists, append — never duplicate existing interfaces
- If the resource maps to an existing `src/features/{feature}/types.ts`, use that file instead and note the location

**Naming conventions:**
- Request body: `{VerbEntity}Request` — e.g., `CreateDailyRecordRequest`, `UpdateLabRecordRequest`
- Response: `{Entity}Response` or `{Entity}Dto` if it matches a known domain entity
- Use `interface` for objects, `type` for unions
- Use `| null` for optional numeric/string fields (medical data can be absent, never undefined)
- Never use `any`

**Example output:**
```typescript
// src/types/daily-record.ts

export interface CreateDailyRecordRequest {
  presion_sistolica: number | null;
  presion_diastolica: number | null;
  frecuencia_cardiaca: number | null;
  peso: number | null;
  cintura: number | null;
  notas: string | null;
}

export interface DailyRecordResponse {
  id: string;
  patientId: string;
  timestamp: string; // ISO 8601
  presion_sistolica: number | null;
  presion_diastolica: number | null;
  frecuencia_cardiaca: number | null;
  peso: number | null;
  cintura: number | null;
  notas: string | null;
}
```

---

## Step 4 — Generate API client function

**Location:** `src/lib/api/{resource}.ts`
- One file per resource — append if file exists, create if it doesn't
- Import from `@/features/auth/store` to get the auth token
- Use `useAuthStore.getState().token` — **not** the hook (client functions are not React components)
- Base URL: read from `process.env.NEXT_PUBLIC_API_URL` with empty string fallback
- Always `throw` on non-ok responses with a tagged message: `[functionName] HTTP {status}`
- Always add explicit TypeScript return type

**Pattern for GET:**
```typescript
// src/lib/api/daily-records.ts
import { useAuthStore } from '@/features/auth/store';
import { DailyRecordResponse } from '@/types/daily-record';

const BASE = process.env.NEXT_PUBLIC_API_URL ?? '';

export async function getPatientDailyRecords(
  patientId: string
): Promise<DailyRecordResponse[]> {
  const token = useAuthStore.getState().token;
  const res = await fetch(`${BASE}/patients/${patientId}/daily-records`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error(`[getPatientDailyRecords] ${res.status}`);
  return res.json();
}
```

**Pattern for POST/PUT/PATCH:**
```typescript
export async function createDailyRecord(
  patientId: string,
  data: CreateDailyRecordRequest
): Promise<DailyRecordResponse> {
  const token = useAuthStore.getState().token;
  const res = await fetch(`${BASE}/patients/${patientId}/daily-records`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(data),
  });
  if (!res.ok) throw new Error(`[createDailyRecord] ${res.status}`);
  return res.json();
}
```

**Pattern for DELETE:**
```typescript
export async function deleteLinkRequest(id: string): Promise<void> {
  const token = useAuthStore.getState().token;
  const res = await fetch(`${BASE}/link-requests/${id}`, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error(`[deleteLinkRequest] ${res.status}`);
}
```

---

## Step 5 — Generate TanStack Query hook

**Location:** `src/features/{feature}/hooks.ts`
- Map the endpoint's resource to its feature folder: `daily-records` → `src/features/patient/`, `link-requests` → `src/features/patient/`, `doctors/{id}/patients` → `src/features/doctor/`
- If no clear feature mapping exists, use `src/lib/hooks/{resource}.ts`
- Append to existing `hooks.ts` if it exists

**GET → `useQuery`:**
```typescript
// src/features/patient/hooks.ts
import { useQuery } from '@tanstack/react-query';
import { getPatientDailyRecords } from '@/lib/api/daily-records';

export function usePatientDailyRecords(patientId: string) {
  return useQuery({
    queryKey: ['daily-records', patientId],
    queryFn: () => getPatientDailyRecords(patientId),
    enabled: !!patientId,
  });
}
```

**POST/PUT/PATCH → `useMutation` with cache invalidation:**
```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { createDailyRecord } from '@/lib/api/daily-records';
import { CreateDailyRecordRequest } from '@/types/daily-record';

export function useCreateDailyRecord(patientId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateDailyRecordRequest) =>
      createDailyRecord(patientId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['daily-records', patientId] });
    },
  });
}
```

**DELETE → `useMutation` with cache invalidation:**
```typescript
export function useDeleteLinkRequest() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteLinkRequest,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['link-requests'] });
    },
  });
}
```

---

## Step 6 — Show usage snippet

After generating all files, print a short usage example showing how to consume the hook inside a component. Do NOT create the component file — just show the snippet inline as a code block.

Example:
```typescript
// Inside a page or component
const { data: records, isLoading } = usePatientDailyRecords(userId ?? '');
const { mutate: createRecord, isPending } = useCreateDailyRecord(userId ?? '');
```

---

## Query key conventions

Always use consistent query keys so invalidations work across the app:

| Resource | Query key pattern |
|---|---|
| `DailyRecord` list | `['daily-records', patientId]` |
| `DailyRecord` single | `['daily-records', patientId, recordId]` |
| `LabRecord` list | `['lab-records', patientId]` |
| `LabRecord` single | `['lab-records', patientId, recordId]` |
| `LinkRequest` list | `['link-requests', userId]` |
| `Patient` profile | `['patient-profile', patientId]` |
| `Doctor` patients | `['doctor-patients', doctorId]` |

If the endpoint doesn't match these, derive the key from `['{resource}', {primary-param}]` and document it in a comment.

---

## Constraints — never break these

1. **Patient data isolation:** Never pass `patientId` from a URL param directly to the API function without first checking it matches `useAuthStore.getState().userId`. Always note this in the generated hook if the endpoint involves patient-specific data.
2. **Doctor access requires accepted link:** If the endpoint is a doctor reading patient data, add a comment in the hook: `// Caller must verify an accepted LinkRequest exists before mounting this hook`.
3. **No `any`** anywhere in generated code.
4. **No raw `fetch` in components** — all fetching goes through the generated hook.
5. **One `useQuery`/`useMutation` per hook** — don't combine multiple API calls in one hook.
