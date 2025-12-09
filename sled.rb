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

  on_linux do
    on_arm do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-linux-aarch64.tar.gz"
      sha256 "e44615061b447443b400d56e7b66f184673c1fe2a1d87a4d3f226c8176e46024"
    end

    on_intel do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-linux-x86_64.tar.gz"
      sha256 "e6860c649e3499eae321b48562d5b8e8e4caeab8e722e766411de46749f5a533"
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
