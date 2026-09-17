class Kbbs < Formula
  desc "Read and send KakaoTalk from a 1990s-style Korean BBS terminal"
  homepage "https://github.com/gum798/kbbs"
  url "https://github.com/gum798/kbbs/archive/refs/tags/v1.260917.0.tar.gz"
  sha256 "fcf284540bb52a8a0b8bb3594abaf07f6def70ccb29ebd1211aa73648cfe759b"
  license "MIT"
  head "https://github.com/gum798/kbbs.git", branch: "master"

  depends_on xcode: ["16.0", :build]
  depends_on :macos

  def install
    # --disable-sandbox: the package uses a SwiftPM build-tool plugin, which writes
    # generated source and cannot run inside Homebrew's sandbox.
    system "swift", "build", "--disable-sandbox", "-c", "release", "--scratch-path", ".build"
    bin.install ".build/release/kbbs"

    # macOS keys Accessibility trust per binary AND per signature. A stable ad-hoc
    # identity means the permission survives a reinstall instead of having to be granted
    # again every time.
    system "codesign", "-s", "-", "--identifier", "dev.kbbs", "--force", bin/"kbbs"
  end

  def caveats
    <<~EOS
      kbbs drives the KakaoTalk app through the macOS Accessibility API, so it needs
      permission before it can read anything:

        System Settings > Privacy & Security > Accessibility > enable kbbs

      KakaoTalk must be running and logged in. kbbs never types your passcode.

      Try it without KakaoTalk or any permission at all:

        kbbs --demo
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kbbs --version")
  end
end
