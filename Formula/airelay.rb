# Homebrew formula for AI Relay. The release workflow fills in the version and
# checksums and attaches the result to each release as `airelay.rb`; copy that
# into a tap (a repo named `homebrew-tap`, under Formula/) and users install with
#
#   brew install chelayel/tap/airelay
#
# A formula, not a cask, on purpose: Homebrew does not quarantine what a formula
# downloads, so the unsigned launcher runs without a Gatekeeper dialog.
class Airelay < Formula
  desc "Gemini on Vertex or Apigee for GitHub Copilot, plus Gemini and Copilot coding agents"
  homepage "https://github.com/Chelayel/ai-relay"
  version "2.4.4"

  on_macos do
    on_arm do
      url "https://github.com/Chelayel/ai-relay/releases/download/v2.4.4/airelay-macos-arm64.tar.gz"
      sha256 "e0b9eb61d9f06637f834c3096a432771948f4ba38e090ea22c29bd6620fd0058"
    end
    on_intel do
      url "https://github.com/Chelayel/ai-relay/releases/download/v2.4.4/airelay-macos-x64.tar.gz"
      sha256 "fea4020aeb0f723fd9ebbf900bc876a434caa6e3df92cd64296d055e35a16675"
    end
  end

  on_linux do
    url "https://github.com/Chelayel/ai-relay/releases/download/v2.4.4/airelay-linux-x64.tar.gz"
    sha256 "aa623464b078244156a4516719fa544165b30cea8f3fd0d96f740fe445a5baec"
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
