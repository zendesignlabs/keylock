#!/bin/zsh
# Renders the app icon and packs it into Resources/icon.icns.
set -euo pipefail
cd "$(dirname "$0")"

TMP=$(mktemp -d)
swift Resources/make-icon.swift "$TMP/icon-1024.png"

ICONSET="$TMP/KeyLock.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
  sips -z $size $size "$TMP/icon-1024.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  dbl=$((size * 2))
  sips -z $dbl $dbl "$TMP/icon-1024.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o Resources/icon.icns
cp "$TMP/icon-1024.png" Resources/icon-1024.png
rm -rf "$TMP"
echo "Wrote Resources/icon.icns"
