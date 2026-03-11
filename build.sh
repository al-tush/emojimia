#!/bin/bash
set -e

FLUTTER_VERSION="3.27.4"
FLUTTER_DIR="$HOME/flutter"

echo "→ Installing Flutter $FLUTTER_VERSION..."
git clone --depth 1 --branch "$FLUTTER_VERSION" \
  https://github.com/flutter/flutter.git "$FLUTTER_DIR"

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "→ Precaching web tools..."
flutter precache --web

echo "→ Getting dependencies..."
flutter pub get

echo "→ Building web..."
flutter build web \
  --dart-define=HUME_API_KEY="$HUME_API_KEY" \
  --release

echo "✓ Build complete → build/web"
