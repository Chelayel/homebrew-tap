# The Homebrew cask for the Mac app. The release workflow fills in the version and the DMG's checksum and copies
# it to Chelayel/homebrew-tap as Casks/petabytes.rb, so: brew install --cask chelayel/tap/petabytes
cask "petabytes" do
  version "2.0.1"
  sha256 "90d1df308cbafa6cf2e5c6ba7c54202fa39cec10ee659fd7877f699c97c08ac8"

  url "https://github.com/Chelayel/petabytes/releases/download/v#{version}/Petabytes-#{version}.dmg"
  name "Petabytes"
  desc "Coding pet that lives on your Dock and reacts to what you do"
  homepage "https://github.com/Chelayel/petabytes"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app updates itself (Check for Updates… in its menu).
  auto_updates true
  depends_on macos: :ventura

  app "Petabytes.app"

  # Signed with the project's own certificate, not notarized by Apple: without this, macOS refuses to open it until
  # it's allowed in Privacy & Security. Installing from this tap is the trust decision.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Petabytes.app"]
  end

  uninstall quit: "com.chelayel.petabytes"

  zap trash: [
    "~/.petabytes",
    "~/Library/Preferences/com.chelayel.petabytes.plist",
  ]
end
