# MorseCodeTrainer-iOS
This is a iOS 18 app that. Its (unfortunately) fully vibe coded using Claude ai.

A SwiftUI recreation of the pocket Morse code trainer card: press-and-hold key,
live dot/dash decoding into letters, an audio beep, a flashlight "LED" flash,
a printed-style reference chart, and record/playback of your own sequences.

## Requirements
- Xcode 16.2
- iOS 18.1.1 (deployment target can be set lower, e.g. 17.0, if you want it to
  run on older devices too — the code has no iOS 18-only APIs)
- A physical iPhone to test sound + flashlight (the Simulator has no torch)

## Setup (5 minutes)

1. Open Xcode 16.2 → **File → New → Project**.
2. Choose **iOS → App**, click Next.
3. Product Name: `MorseCodeTrainer`. Interface: **SwiftUI**. Language: **Swift**.
   Uncheck "Use Core Data" and "Include Tests" (not needed).
4. Save it anywhere, e.g. `~/Developer/MorseCodeTrainer`.
5. In Finder, **delete** the auto-generated `ContentView.swift` that Xcode
   created (keep `MorseCodeTrainerApp.swift` for now, you'll overwrite it).
6. Drag all files from this folder's `MorseCodeTrainer/` subfolder into the
   Xcode project navigator (into the `MorseCodeTrainer` group), replacing the
   app file when prompted. Make sure "Copy items if needed" is checked and the
   `MorseCodeTrainer` target is checked. You should end up with 10 files:
   `MorseCodeTrainerApp`, `RootView`, `ContentView`, `TrainingView`,
   `SettingsView`, `AppSettings`, `MorseInputEngine`, `MorseCode`,
   `ToneGenerator`, `TorchController`.
7. Select the project in the navigator → the `MorseCodeTrainer` target →
   **Info** tab → add a new row:
   - Key: `Privacy - Camera Usage Description`
   - Value: `Used to flash the torch as a Morse code light signal.`
   (Required because toggling the flashlight uses `AVCaptureDevice`.)
8. Select the target → **Signing & Capabilities** → set your Team so it can
   build to a real device.
9. Set the deployment target (target → **General** → Minimum Deployments) to
   whatever you want to support — `17.0`+ is fine, or `18.1` to match your SDK.
10. Plug in your iPhone, select it as the run destination, and hit **Run**.

## How it works
- **MorseCode.swift** — the dot/dash ↔ letter lookup table.
- **MorseInputEngine.swift** — measures how long you hold the key to classify
  dots vs. dashes, detects pauses to auto-complete letters/words, and records
  a tap timeline for playback.
- **ToneGenerator.swift** — a live 700 Hz sine tone via `AVAudioEngine`, so the
  beep starts/stops instantly with your finger (no sample-based latency).
- **TorchController.swift** — drives the iPhone's flashlight as the LED output.
- **AppSettings.swift** — persists which UI mode (Classic / Training) is active.
- **RootView.swift** — shows whichever mode is selected.
- **ContentView.swift** — **Classic mode**: key button, live pattern/decoded-text
  display, sound/light toggles, record/play buttons, and the reference chart sheet.
- **TrainingView.swift** — **Training mode**: the whole chart is on screen at
  once. As you hold dots/dashes, every letter whose code still matches your
  pattern-so-far lights up orange, narrowing down live; the instant your
  pattern completes a letter, that cell flashes green — the same "grid lights
  up as you tap" effect from the original card's demo video.
- **SettingsView.swift** — segmented control to switch between the two modes.

## Using the app
- **Press and hold** the orange circle: short tap = dot, longer hold = dash.
- Pause briefly and the app auto-finalizes the letter; pause longer and it
  adds a space (word break) — same rhythm as real Morse.
- Tap the speaker/flashlight icons to toggle audio and torch feedback.
- **Classic mode**: tap **record**, tap out a sequence, tap record again to
  stop, then hit **play** to have the app replay it back via tone + torch
  flashes. Tap the chart icon (top right) for the full reference.
- **Training mode**: just start tapping — watch the grid narrow down to the
  matching letters as you go, and flash green when you complete one.
- Tap the **gear icon** in either mode to open Settings and switch between
  Classic and Training.
