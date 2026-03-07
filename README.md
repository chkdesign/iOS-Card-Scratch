# ScratchCardDemo

A SwiftUI iOS demo app (iOS 17+) that simulates a scratch card with:
- touch-based scratching
- reveal threshold logic
- procedural scratch/win sounds
- haptic feedback
- confetti celebration

## What I learned building this

1. **SwiftUI state flow**
   - `@State` drives scratch path, reveal state, and confetti state.
   - `@StateObject` keeps audio/haptic manager alive across view updates.

2. **Gesture-driven interaction**
   - `DragGesture(minimumDistance: 0)` captures continuous scratch points.
   - Gesture start/end is used to start/stop sound and accumulate scratch time.

3. **Scratch effect with `Canvas`**
   - A top overlay is drawn first.
   - Blend mode `.clear` erases circular regions where the user drags.
   - This reveals the card underneath in real time.

4. **Reveal logic design**
   - Reveal is gated by both:
     - covered area threshold (`>= 45%`), and
     - minimum scratching duration (`>= 2 seconds`).
   - This makes revealing feel intentional, not accidental.

5. **Procedural audio with `AVAudioEngine`**
   - Scratch sound is generated as a looping buffer of shaped noise.
   - Win sound is synthesized from layered sine waves.
   - No external audio files are required.

6. **Haptics for interaction quality**
   - Light haptics while scratching (throttled to avoid overload).
   - Success + impact haptics on reveal/reset.

7. **Composable UI architecture**
   - Components are split into focused files:
     - `ScratchCardView` (screen + behavior)
     - `ScratchComponents` (UI pieces)
     - `ScratchFeedbackManager` (sound + haptics)
     - `Confetti` (celebration animation)

## File structure

- `ScratchCardDemo/ScratchCardDemo/ScratchCardDemoApp.swift`
- `ScratchCardDemo/ScratchCardDemo/ScratchCardDemoView.swift`
- `ScratchCardDemo/ScratchCardDemo/ScratchCardView.swift`
- `ScratchCardDemo/ScratchCardDemo/ScratchFeedbackManager.swift`
- `ScratchCardDemo/ScratchCardDemo/ScratchComponents.swift`
- `ScratchCardDemo/ScratchCardDemo/Confetti.swift`

## Run

1. Open `ScratchCardDemo/ScratchCardDemo.xcodeproj`
2. Select an iOS Simulator
3. Press `Cmd + R`
