#!/bin/zsh
# Signs, notarizes, and staples KeyLock.app for distribution.
# Prereqs (one-time):
#   1. Apple Developer Program membership
#   2. A "Developer ID Application" certificate installed in your keychain
#   3. xcrun notarytool store-credentials keylock --apple-id <you> --team-id <TEAM>
set -euo pipefail
cd "$(dirname "$0")"

IDENTITY="${1:-Developer ID Application}"

./build-app.sh
codesign --force --deep --options runtime --sign "$IDENTITY" build/KeyLock.app

ditto -c -k --keepParent build/KeyLock.app build/KeyLock.zip
xcrun notarytool submit build/KeyLock.zip --keychain-profile keylock --wait
xcrun stapler staple build/KeyLock.app

ditto -c -k --keepParent build/KeyLock.app build/KeyLock-notarized.zip
echo "Share build/KeyLock-notarized.zip"
