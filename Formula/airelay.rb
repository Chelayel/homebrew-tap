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
  version "1.8.3"

  on_macos do
    on_arm do
      url "https://github.com/Chelayel/ai-relay/releases/download/v1.8.3/airelay-macos-arm64.tar.gz"
      sha256 "7e02b58bf99d310133340b3bd79ac9877f409b0c8e2a057143b893f7e83b4d2e"
    end
    on_intel do
      url "https://github.com/Chelayel/ai-relay/releases/download/v1.8.3/airelay-macos-x64.tar.gz"
      sha256 "661383e193dca6414bf8f89b06791d4b4c5520496a8adbd120c8eb008c160e7e"
    end
  end

  on_linux do
    url "https://github.com/Chelayel/ai-relay/releases/download/v1.8.3/airelay-linux-x64.tar.gz"
    sha256 "4d09e34afe652894a6655e01574874b805027408369efec968493347a18a34d7"
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

  # Homebrew only writes under its own prefix, so it cannot remove an airelay
  # that another route installed — install.sh's in ~/.local/bin, the .pkg's in
  # /Applications, the .deb's in /opt — and the first of those usually comes
  # before Homebrew's bin on PATH, so the old copy keeps running after a
  # successful install. Say so, with the command that fixes it.
  def caveats
    script = File.join(Dir.home, ".local", "bin", "airelay")
    others = []
    if File.exist?(script) || File.symlink?(script)
      others << "#{script} (install.sh):\n    rm #{script} && rm -rf #{File.join(Dir.home, ".local", "share", "airelay")}"
    end
    if File.directory?("/Applications/airelay.app")
      others << "/Applications/airelay.app (the .pkg installer):\n    sudo rm -rf /Applications/airelay.app /usr/local/bin/airelay && sudo pkgutil --forget com.chelayel.airelay"
    end
    others << "/opt/airelay (the .deb package):\n    sudo apt remove airelay" if File.directory?("/opt/airelay")
    return if others.empty?

    <<~EOS
      airelay is also installed another way. Whichever comes first on your PATH
      is the one that runs, so remove the one you no longer want:
        #{others.join("\n  ")}
      Then run `hash -r` and check with `type -a airelay`.
    EOS
  end

  test do
    assert_match "AI Relay", shell_output("#{bin}/airelay --help")
  end
end
