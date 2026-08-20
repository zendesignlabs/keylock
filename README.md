# KeyLock

Lock your keyboard. Clean it. Go absolutely ham on it.

KeyLock is a tiny macOS app that blocks all keyboard input — keys, modifiers, media keys — while your mouse keeps working. So you can scrub every keycap without sending keysmashed gibberish to your friends and colleagues. ([The backstory](https://zenlara.com/keylock), from the "Things I Make" series.)

- One big lock button with an animated ring
- Optional auto-unlock timer (30s / 1m / 3m / 5m), or lock until you click again
- Blocks input with a system event tap; the mouse stays live so you can always unlock
- Signed and notarized — no Gatekeeper warnings

## Install

### Homebrew (recommended)

```
brew tap zendesignlabs/tap
brew trust zendesignlabs/tap   # one-time, Homebrew asks this for all third-party taps
brew install --cask keylock
```

### Direct download

Grab `KeyLock-notarized.zip` from the [latest release](https://github.com/zendesignlabs/keylock/releases/latest), unzip, and drop `KeyLock.app` into Applications.

### Build from source

```
git clone https://github.com/zendesignlabs/keylock.git
cd keylock
./build-app.sh
open build/KeyLock.app
```

Requires macOS 14+ and Xcode command line tools.

## First run

macOS gates event taps behind Accessibility permission. On first lock, KeyLock will point you to System Settings → Privacy & Security → Accessibility — flip the toggle and you're set.

## Support

If KeyLock saved your group chats from `sdfghjkl;`, you can [buy me a coffee](https://buy.stripe.com/6oU14nbAtfBvawR76n38406) — there's a cup in the app's footer too.
