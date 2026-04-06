# Flutter macOS multi-window first-frame repro

This is a minimal macOS-focused Flutter project intended to isolate first-frame
artifacts in Flutter's multi-window API.

## What it does

- Opens two identical Flutter-backed macOS windows.
- Gives each window a colored native host background so any gap before Flutter
  paints is obvious.
- Uses Flutter's supported multi-window path so the behavior is easier to
  discuss in an upstream Flutter issue.

## Why this exists

The main app has macOS-specific dialog reveal logic because window visibility
and Flutter rendering do not always line up cleanly. This repro narrows the
question to:

Can Flutter's supported macOS multi-window path show native windows before
placement, host styling, or Flutter content are ready?

If the answer is yes, that is useful evidence for a Flutter macOS windowing
issue or API gap.

## Run

```bash
flutter run -d macos
```

## What to watch for

- Do two windows appear?
- Does either window appear in the wrong position before settling?
- Does either window appear black before the host background color is visible?
- Does either window show only the host background for a few frames before the
  white Flutter panel appears?
