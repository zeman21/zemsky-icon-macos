#!/usr/bin/env bash
# Builds PixelMate.app + DMG and prints the sha256 for the Homebrew cask.
set -euo pipefail
cd "$(dirname "$0")/.."
export PATH="$HOME/.cargo/bin:$PATH"
npm run tauri build -- --target universal-apple-darwin --bundles app
./scripts/make-dmg.sh
DMG=$(ls -t src-tauri/target/release/bundle/dmg/PixelMate_*.dmg | head -1)
echo
echo "App: src-tauri/target/universal-apple-darwin/release/bundle/macos/PixelMate.app"
echo "DMG: $DMG"
echo "sha256: $(shasum -a 256 "$DMG" | cut -d' ' -f1)"
