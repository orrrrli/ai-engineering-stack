#!/bin/bash
# PreToolUse(Bash) gate: blocks `gh pr merge` unless every CI check on that PR passed.
# For repos whose default branch has no required checks, where GitHub itself won't stop a red merge.
# A repo with no CI at all is blocked too (no checks reported): wire it only where CI exists.
# Any other Bash command exits at the first test, so the cost per call is one jq.
cmd=$(jq -r '.tool_input.command // empty')
# Only a real call: `gh pr merge` at the start of a line or after ; & | ( — not the words
# inside a PR body, a heredoc or an echo.
merge=$(grep -oE '(^|[;&|(])[[:space:]]*gh pr merge[^;&|]*' <<<"$cmd" | head -1)
[ -n "$merge" ] || exit 0

pr=$(grep -oE 'merge +[0-9]+' <<<"$merge" | grep -oE '[0-9]+')
repo=$(grep -oE "(-R|--repo)[ =]+['\"]?[^ '\"]+" <<<"$merge" | sed -E "s/^(-R|--repo)[ =]+['\"]?//")

out=$(gh pr checks ${pr:+"$pr"} ${repo:+-R "$repo"} 2>&1)
status=$?
[ $status -eq 0 ] && exit 0

# 8 = checks still pending; anything else = failed, no checks, or gh couldn't resolve the PR.
reason=$([ $status -eq 8 ] && echo "CI still running" || echo "CI not green")
echo "merge-gate: blocked — $reason on PR ${pr:-<current branch>}${repo:+ ($repo)}. Wait with \`gh pr checks ${pr} ${repo:+-R $repo} --watch\`, then merge.
$out" >&2
exit 2
