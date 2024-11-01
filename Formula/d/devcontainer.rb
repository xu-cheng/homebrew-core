class Devcontainer < Formula
  desc "Reference implementation for the Development Containers specification"
  homepage "https://containers.dev"
  url "https://registry.npmjs.org/@devcontainers/cli/-/cli-0.72.0.tgz"
  sha256 "dce95550333869e03660f98d4963f898f204af9a961f324ff2b6be048a4704db"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia:  "5838ef0317746eae9049e600db863a02a09d63b414497269028f652317a9db36"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "5838ef0317746eae9049e600db863a02a09d63b414497269028f652317a9db36"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "5838ef0317746eae9049e600db863a02a09d63b414497269028f652317a9db36"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5838ef0317746eae9049e600db863a02a09d63b414497269028f652317a9db36"
    sha256 cellar: :any_skip_relocation, sonoma:         "5a52a9d1b591439d7c14d141049dd7551ce671c2cc8abbfc732a407f8c0e3234"
    sha256 cellar: :any_skip_relocation, ventura:        "5a52a9d1b591439d7c14d141049dd7551ce671c2cc8abbfc732a407f8c0e3234"
    sha256 cellar: :any_skip_relocation, monterey:       "5a52a9d1b591439d7c14d141049dd7551ce671c2cc8abbfc732a407f8c0e3234"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5838ef0317746eae9049e600db863a02a09d63b414497269028f652317a9db36"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    ENV["DOCKER_HOST"] = "/dev/null"
    # Modified .devcontainer/devcontainer.json from CLI example:
    # https://github.com/devcontainers/cli#try-out-the-cli
    (testpath/".devcontainer.json").write <<~EOS
      {
        "name": "devcontainer-homebrew-test",
        "image": "mcr.microsoft.com/devcontainers/rust:0-1-bullseye"
      }
    EOS
    output = shell_output("#{bin}/devcontainer up --workspace-folder .", 1)
    assert_match '{"outcome":"error","message":"', output
  end
end
