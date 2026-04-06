# Flutter macOS dialog reveal repro

This is a minimal macOS-focused Flutter project intended to isolate the
"window becomes visible before Flutter content is safely painted" problem.

## What it does

- The native macOS host window starts hidden.
- Flutter builds a dialog-like surface with obvious content.
- After Flutter reports a frame and waits for frame timing data, Dart tells the
  native side to show the window.
- The `Hide and Reveal Again` button repeats the same hidden-to-visible path
  without restarting the app.

## Why this exists

The main app has substantial macOS-specific dialog reveal logic because native
window visibility and Flutter rendering do not always line up cleanly. This
repro is meant to answer a narrower question:

Can a small standalone macOS Flutter app still expose a blank or unpainted
first frame even when the native window stays hidden until Flutter signals
"ready"?

If the answer is yes here too, that is a stronger Flutter/macOS embedder bug
report candidate.

## Run

```bash
cd experiments/macos_dialog_first_frame_repro
flutter run -d macos
```

## What to watch for

- At initial launch, does the window appear already painted?
- After clicking `Hide and Reveal Again`, does the window reappear fully drawn?
- Do you ever see a white, gray, or black flash before the dialog surface is
  visible?
