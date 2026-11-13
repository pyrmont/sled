class Sled < Formula
  desc "Command-line utility for Advent of Code"
  homepage "https://github.com/pyrmont/sled"
  version "0.2.0"

  on_macos do
    on_arm do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-macos-aarch64.tar.gz"
      sha256 "d18666b30bab043e8d587c3abe623f974e3979a55cdbc5e15a14f3ca90aad4d2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-linux-aarch64.tar.gz"
      sha256 "ae43a62fac50b1ae3203f16801bcfe58e610ffab10fb91fd97bc2827145aee6a"
    end

    on_intel do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-linux-x86_64.tar.gz"
      sha256 "0842ce3dce248f2e31eb0cf08e5d459c80efb647475e88566eed37e7fc29a43a"
    end
  end

  def install
    bin.install "sled"
    man1.install "sled.1"
    doc.install "README.md", "LICENSE"
  end

  test do
    assert_match "sled", shell_output("#{bin}/sled --help")
  end
end
