class Sled < Formula
  desc "Command-line utility for Advent of Code"
  homepage "https://github.com/pyrmont/sled"
  version "0.1.1"

  on_macos do
    on_arm do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-macos-aarch64.tar.gz"
      sha256 "ffe5d5773ed3556fde1e24f9b155e96009bf7b1ca6f49eefc5765e1b99492bd9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-linux-aarch64.tar.gz"
      sha256 "b4566d186493067a01c3c75e37258028d113c7df537487482c335e783513c423"
    end

    on_intel do
      url "https://github.com/pyrmont/sled/releases/download/v#{version}/sled-v#{version}-linux-x86_64.tar.gz"
      sha256 "db233aca1ee22c392a4d760a4f7f0761170a8fc5ab5037b41d784e3ee21b954c"
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
