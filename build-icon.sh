#!/bin/zsh
# Packs the icon artwork (from icon.pen, exported as "SVG Keyboard Icon.webp")
# onto the standard 1024pt macOS icon grid and into Resources/icon.icns.
set -euo pipefail
cd "$(dirname "$0")"

TMP=$(mktemp -d)
swift Resources/pack-icon.swift "SVG Keyboard Icon.webp" Resources/icon-1024.png
sips -z 1024 1024 Resources/icon-1024.png >/dev/null

ICONSET="$TMP/KeyLock.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
  sips -z $size $size Resources/icon-1024.png --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  dbl=$((size * 2))
  sips -z $dbl $dbl Resources/icon-1024.png --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o Resources/icon.icns
rm -rf "$TMP"
echo "Wrote Resources/icon.icns"
