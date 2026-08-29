# MorseCodeTrainer-iOS
This is a iOS 18 app that. Its (unfortunately) fully vibe coded using Claude ai.

A SwiftUI recreation of the pocket Morse code trainer card: press-and-hold key,
live dot/dash decoding into letters, an audio beep, a flashlight "LED" flash,
a printed-style reference chart, and record/playback of your own sequences.

## Requirements
- Xcode 16.2
- iOS 18 (deployment target can be set lower, e.g. 17.0, if you want it to
  run on older devices too — the code has no iOS 18-only APIs)

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
