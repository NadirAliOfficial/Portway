#!/bin/bash
# Builds Portway and packages it as a proper .app bundle, then launches it.
set -euo pipefail

CONFIG="${1:-debug}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/.build/Portway.app"
BINARY_NAME="Portway"

echo "==> Building ($CONFIG)"
swift build --package-path "$ROOT_DIR" -c "$CONFIG"

BIN_PATH="$ROOT_DIR/.build/$CONFIG/$BINARY_NAME"

echo "==> Packaging app bundle"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/$BINARY_NAME"
cp "$ROOT_DIR/Sources/Portway/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"

echo "==> Ad-hoc signing"
codesign --force --deep --sign - "$APP_DIR"

echo "==> Launching"
open "$APP_DIR"

echo "Done: $APP_DIR"
