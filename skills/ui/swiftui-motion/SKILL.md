---
name: swiftui-motion
stacks: [ios]
description: Build motion in a SwiftUI app (iOS 17+), making the decisions in the order that decides whether it feels right — should it animate at all, what purpose, which API, which spring, how it interrupts, how a drag hands off to the animation, which haptic, and how it degrades under Reduce Motion. Writes the implementation with stock SwiftUI only. Use when animating a view, adding a transition, press feedback, a custom drag or swipe, a haptic, or when motion feels sluggish, bouncy or disconnected. For static screen design use apple-design.
---

# SwiftUI Motion

Turn a request for motion into SwiftUI code that would pass a strict review the first time. iOS 17
minimum, no third-party libraries.

Two failure modes, and the first is worse:

1. **Animating something that shouldn't animate.** The gate below exists to produce zero lines of
   code sometimes. That is a success.
2. **The right thing with the wrong ingredients:** a bouncy spring on a menu, a timing curve on
   something the user can grab, a custom sheet when `.sheet` already exists.

Never present motion options as a menu. Make the call, state the reason in one line, write the code.

## Hard rules

1. **Run the sequence in order.** Steps 1 and 2 gate everything.
2. **Stock components first.** `NavigationStack`, `.sheet`, `List`, swipe actions, `TabView`,
   `Toggle` and the system button styles already move the way iOS users expect. Do not re-animate
   them or rebuild them to get custom motion.
3. **No invented values.** Springs and durations come from the tables below.
4. **Extend the project's motion tokens if they exist** (a shared `Animation` extension). Don't add a
   second set.
5. **Reduce Motion ships with the animation**, not as a follow-up.

## The build sequence

### 1. Should this animate at all?

| How often the user sees it | Decision |
| --- | --- |
| Many times per session (a row tap, a toggle in a long list, a keyboard action) | Stock behavior only, or nothing |
| Several times a day (a filter change, a status flip) | Short and subtle, no bounce |
| Occasional (a sheet, a confirmation, a new item appearing) | Standard motion |
| Rare (onboarding, a first success, a milestone) | The delight budget lives here |

If the request fails this gate, say so and offer the non-motion alternative (an instant state change,
a static affordance).

### 2. What is the purpose?

Name it before continuing:

- **Feedback:** the interface heard the touch.
- **Spatial consistency:** where something came from or went.
- **State indication:** a state change made legible.
- **Preventing a jarring change:** content that would otherwise teleport.
- **Delight:** only in the rare tier.

Can't name it? Don't build it. Data the user is reading or acting on (amounts, lists, dates) never
moves for style.

### 3. Pick the API: cheapest that works

Walk down; stop at the first that fits.

| Need | API |
| --- | --- |
| The motion a stock component already has | Nothing. Use the component |
| A state change that should animate | `.animation(_:value:)` scoped to that value, or `withAnimation` in the action |
| A view appearing or disappearing | `.transition(...)` |
| A number or SF Symbol changing in place | `.contentTransition(.numericText(value:))`, `.symbolEffect(_:value:)` |
| An element moving between two places in the hierarchy | `matchedGeometryEffect` |
| A short multi-step effect on a trigger | `phaseAnimator(_:trigger:)` |
| Several properties on independent timelines | `keyframeAnimator(initialValue:trigger:)` |
| The user drags or flicks something with no stock equivalent | `DragGesture` + springs (step 6) |

### 4. Pick the properties

- **Prefer `opacity`, `scaleEffect`, `offset` and `rotationEffect`** for anything that moves often.
  They don't re-run layout. Animating `frame` or `padding` is fine for a one-shot state change, not
  for something that moves every second.
- **Never scale from 0.** Nothing in the real world appears from nothing. Use
  `.scale(scale: 0.95).combined(with: .opacity)`.
- **Anchor to the trigger.** A menu or popover grows from the control that opened it:
  `.scale(scale: 0.95, anchor: .topTrailing)`. Full-screen modals stay centered.
- **Exit the way it entered.** `.move(edge: .bottom)` leaves through the bottom. Use `.asymmetric`
  only with a reason you can state.
- **Decompose 2D drag motion into independent X and Y**, so different velocities don't desync.

### 5. Springs

Since iOS 17 the default SwiftUI animation is a spring. Think in Apple's two parameters:

- **`duration`**: the perceptual pace (Apple's "response"). Not a fixed end time.
- **`bounce`**: `0` is critically damped, no overshoot. Roughly `1 - dampingRatio`.

| Interaction | Animation |
| --- | --- |
| Default for UI state changes | `.spring(duration: 0.4, bounce: 0)` or `.smooth` |
| Press feedback | `.spring(duration: 0.15, bounce: 0)` |
| Something repositions on screen | `.spring(duration: 0.4, bounce: 0)` |
| A drawer or card released after a flick | `.spring(duration: 0.3, bounce: 0.2)` |
| Rotation after a gesture | `.spring(duration: 0.4, bounce: 0.2)` |

- **Bounce only when the gesture carried momentum** (a flick, a throw, a drag release). Overshoot on a
  menu that just appeared feels wrong; on a card you flicked it feels right. Keep it at 0.1-0.3.
- **Most UI settles in 0.4s or less.** Slower reads as sluggish.
- **Timing curves only for constant or non-interactive motion:** `.linear` for progress, `.easeOut`
  for a fade nobody can interrupt. **Never `.easeIn` on UI**: it delays the moment the user watches.

### 6. Interruption and gestures

**Interruptibility is the most important property.** The user must be able to grab anything mid-flight.

- **Springs retarget for free.** A new `.spring` on the same property replaces the running one and
  keeps its velocity. A timing curve restarts with a visible seam, so anything that can be triggered
  twice in a second uses a spring.
- **Never lock input during a transition.** No `.disabled(isAnimating)`, no `allowsHitTesting(false)`
  while something moves.
- **Track 1:1 during the drag, with no animation.** The element stays glued to the finger and respects
  where it was grabbed. Feedback is continuous, not only on release.
- **Project the landing point.** Pick the snap target from `predictedEndTranslation`, not from where
  the finger let go. That is what makes a flick throw the element.
- **Hand off the velocity.** Pass the release velocity into the spring so there's no seam between the
  drag and the animation. `interpolatingSpring` wants it relative to the remaining distance.
- **Rubber-band at the edges.** Resist progressively past a boundary instead of a hard stop.

```swift
struct DismissableCard: View {
  @State private var offset: CGFloat = 0
  private let height: CGFloat = 400

  var body: some View {
    CardContent()
      .offset(y: offset)
      .gesture(
        DragGesture()
          .onChanged { value in
            let y = value.translation.height
            offset = y >= 0 ? y : rubberband(y, dimension: height)   // 1:1, no animation
          }
          .onEnded { value in
            let target: CGFloat = value.predictedEndTranslation.height > height / 2 ? height : 0
            let distance = target - offset
            let relativeVelocity = distance == 0 ? 0 : value.velocity.height / distance
            withAnimation(.interpolatingSpring(duration: 0.3, bounce: 0.2,
                                               initialVelocity: relativeVelocity)) {
              offset = target
            }
          }
      )
  }
}

/// Past the boundary the element follows less and less, the way real things slow before they stop.
func rubberband(_ overshoot: CGFloat, dimension: CGFloat, constant: CGFloat = 0.55) -> CGFloat {
  (overshoot * dimension * constant) / (dimension + constant * abs(overshoot))
}
```

**Press feedback** belongs on touch-down. Stock button styles already do it; a custom style does it
like this:

```swift
struct PressableStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
      .animation(.spring(duration: 0.15, bounce: 0), value: configuration.isPressed)
  }
}
```

### 7. Haptics

`.sensoryFeedback(_:trigger:)`. Three rules:

1. **Causality.** Trigger it on the event that caused it: the toggle flipping, the item snapping home.
2. **Harmony.** The motion and the haptic fire on the same frame. Drive both from the same state
   change, never from a delayed task.
3. **Utility.** Reserve haptics for moments that matter: `.success`, `.warning`, `.error`, `.selection`
   for a discrete value change, `.impact` for a snap. Over-feedback trains people to ignore it.

```swift
Button("Confirm payment") { isPaid = true }
  .sensoryFeedback(.success, trigger: isPaid)   // same state change drives the checkmark animation
```

### 8. Reduce Motion

SwiftUI does not tone down your custom animations on its own. Read the setting and swap movement for
a cross-fade. Reduce Motion means gentler, not none: keep opacity and color changes that help
comprehension, drop slides, scale, bounce and parallax.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

.transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
.animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.3, bounce: 0.2), value: isOpen)
```

## Never ship

| Never | Instead |
| --- | --- |
| A custom sheet, drawer or navigation transition where a stock one exists | `.sheet`, `NavigationStack`, `.presentationDetents` |
| `.animation(_:)` with no `value:` | `.animation(_:value:)` or `withAnimation` |
| `.scale` from 0 | `.scale(scale: 0.95).combined(with: .opacity)` |
| `.easeIn` on UI | A spring, or `.easeOut` for a plain fade |
| A timing curve on something the user can grab or retrigger | `.spring` |
| Bounce on something that didn't come from a gesture | `bounce: 0` |
| Snapping to the nearest point from the release position | `predictedEndTranslation` |
| Dropping the release velocity | `interpolatingSpring(..., initialVelocity:)` |
| A hard stop at a boundary | `rubberband` |
| Input disabled while animating | Let the spring retarget |
| A haptic fired from a delayed task | `.sensoryFeedback` on the same state change |
| No Reduce Motion branch | `.opacity` fallback |
| Everything entering at once | A 30-80ms stagger per item |

## Output

Write the code. Then, in a few lines at most:

- **Gate:** frequency tier and purpose. If something was rejected, which and why.
- **Ingredients:** API, properties, spring, haptic, one line each.
- **Feel-check:** what can't be judged from code. Play it with Simulator > Debug > Slow Animations,
  try the gesture on a real device (the Simulator plays no haptics), and look again the next day.

## Source

Adapted from [emilkowalski/skills](https://github.com/emilkowalski/skills) (MIT, commit `e8a175d`,
read 2026-10-09): the build sequence, gate tables and never-ship list from `animate`, and sections
1-11 and 13 of `apple-design` (response, interruptibility, springs, velocity handoff, momentum,
rubber-banding, haptics). Changed: every CSS, Framer Motion and Pointer Events example rewritten for
SwiftUI on iOS 17, checked against Apple's SwiftUI documentation; the "pick the tool" table rebuilt
around stock components; Apple's projection formula replaced with `predictedEndTranslation`, which
SwiftUI already computes. Left out: hover gating and `transform-origin`, which don't exist on iPhone.
