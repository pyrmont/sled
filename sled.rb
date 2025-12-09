class Sled < Formula
  desc "Command-line utility for Advent of Code"
  homepage "https://github.com/pyrmont/sled"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-macos-aarch64.tar.gz"
      sha256 "ff8e5d008b40f345482686bfa18aa7d8fa3a2fdec402265d42d5d64e165d3fcf"
    end
  end

  def install
    cd "sled-v#{version}" do
      bin.install "sled"
      man1.install "sled.1"
      doc.install "README.md", "LICENSE"
    end
  end

  test do
    assert_match "sled", shell_output("#{bin}/sled --help")
  end
end
