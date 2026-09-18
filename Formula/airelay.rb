# Homebrew formula for AI Relay. The release workflow fills in the version and
# checksums and attaches the result to each release as `airelay.rb`; copy that
# into a tap (a repo named `homebrew-tap`, under Formula/) and users install with
#
#   brew install chelayel/tap/airelay
#
# A formula, not a cask, on purpose: Homebrew does not quarantine what a formula
# downloads, so the unsigned launcher runs without a Gatekeeper dialog.
class Airelay < Formula
  desc "Claude, Gemini and Copilot as CLI coding agents"
  homepage "https://github.com/Chelayel/ai-relay"
  version "1.1.0"

  on_macos do
    on_arm do
      url "https://github.com/Chelayel/ai-relay/releases/download/v1.1.0/airelay-macos-arm64.tar.gz"
      sha256 "03b922ce13cbd2fb0f67feed80ca6dbba36fb0e38f4aa768cc52aa2ade0c3cb7"
    end
    on_intel do
      url "https://github.com/Chelayel/ai-relay/releases/download/v1.1.0/airelay-macos-x64.tar.gz"
      sha256 "123e1e5b1eea444ff141e14d84394f4b1a94ae15ab5f276c13d4d912c020bb78"
    end
  end

  on_linux do
    url "https://github.com/Chelayel/ai-relay/releases/download/v1.1.0/airelay-linux-x64.tar.gz"
    sha256 "8002a2f8b651d5b7f03e73893b875e34edd611c08fd8703db5e13ec3cd8c7678"
  end

  def install
    # The archive is a self-contained app image with its own Java runtime.
    libexec.install Dir["*"]
    launcher = OS.mac? ? libexec/"Contents/MacOS/airelay" : libexec/"bin/airelay"
    # A wrapper, not `bin.install_symlink`: Homebrew's symlinks are relative, and
    # the macOS launcher resolves a relative link against the current directory
    # when it looks for its own runtime — it starts from the wrong place and
    # fails with "Error opening .../app/airelay.cfg".
    (bin/"airelay").write <<~SH
      #!/bin/sh
      exec "#{launcher}" "$@"
    SH
  end

  test do
    assert_match "AI Relay", shell_output("#{bin}/airelay --help")
  end
end
