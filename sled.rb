class Sled < Formula
  desc "command-line utility for Advent of Code"
  homepage "https://github.com/pyrmont/sled"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/pyrmont/sled/releases/download/v0.1.0/sled-macos-aarch64-v0.1.0.tar.gz"
      sha256 "ff8e5d008b40f345482686bfa18aa7d8fa3a2fdec402265d42d5d64e165d3fcf"
    end
  end

  def install
    bin.install "sled"
    man1.install "man/man1/sled.1"
    doc.install "README.md", "LICENSE"
  end

  test do
    assert_match "sled", shell_output("#{bin}/sled --help")
  end
end
