# KeyLock

A small, good-looking macOS utility that locks your keyboard so you can clean it — a redesigned take on KeyboardCleanTool.

- One big lock button with an animated ring
- Optional auto-unlock timer (30s / 1m / 3m / 5m, or lock until tapped again)
- Blocks key presses, modifiers, and media keys via a CGEventTap; the mouse keeps working so you can always unlock
- Requires Accessibility permission (System Settings → Privacy & Security → Accessibility)

## Build

```
./build-app.sh
open build/KeyLock.app
```

Requires macOS 14+ and Xcode command line tools.
