# Homebrew Cask for a custom tap.
#
# Setup (once you have published a GitHub release):
#   1. Create a repo named  homebrew-pixelmate  and put this file at  Casks/pixelmate.rb
#   2. Upload PixelMate_<version>_universal.dmg to a GitHub release tagged v<version>
#   3. Replace YOUR_GITHUB_USER and the sha256 (printed by `npm run release`)
#   4. Users install with:
#        brew tap YOUR_GITHUB_USER/pixelmate
#        brew install --cask pixelmate
cask "pixelmate" do
  version "0.1.0"
  sha256 "REPLACE_WITH_SHA256_OF_DMG"

  url "https://github.com/YOUR_GITHUB_USER/pixelmate/releases/download/v#{version}/PixelMate_#{version}_universal.dmg"
  name "PixelMate"
  desc "Lightweight pixel pet for the macOS desktop"
  homepage "https://github.com/YOUR_GITHUB_USER/pixelmate"

  depends_on macos: ">= :big_sur"

  app "PixelMate.app"

  zap trash: [
    "~/Library/Application Support/com.pixelmate.app",
    "~/Library/LaunchAgents/PixelMate.plist",
    "~/Library/WebKit/com.pixelmate.app",
    "~/Library/Caches/com.pixelmate.app",
  ]
end
