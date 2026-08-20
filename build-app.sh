#!/bin/zsh
# Builds KeyLock.app from the SwiftPM executable.
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

APP=build/KeyLock.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/KeyLock "$APP/Contents/MacOS/KeyLock"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"

echo "Built $APP"
