# Reference: https://github.com/macvim-dev/macvim/wiki/building
class Macvim < Formula
  desc "GUI for vim, made for macOS"
  homepage "https://github.com/macvim-dev/macvim"
  url "https://github.com/macvim-dev/macvim/archive/snapshot-163.tar.gz"
  version "8.2-163"
  sha256 "3af72f22b25cf4f94b1b6e27a74d74bdefa8ed1529fe6edec59ae2756b3ca209"
  head "https://github.com/macvim-dev/macvim.git"

  bottle do
    cellar :any
    sha256 "e970af58d654178888bb0ba2a953c4c12611b666fab04f9f2e3a8820d3c4527c" => :catalina
    sha256 "a74cd5165d1fd5ad7cc4c153acd6d642e4e64b1e6d0b33285bcf5be3fc95b203" => :mojave
    sha256 "aad6f1ca9577d5bd5572647420c541049778dd03e7f18a6368314118e9de9f85" => :high_sierra
  end

  depends_on :xcode => :build
  depends_on "cscope"
  depends_on "lua"
  depends_on "python"
  depends_on "ruby"

  conflicts_with "vim",
    :because => "vim and macvim both install vi* binaries"

  def install
    # Avoid issues finding Ruby headers
    ENV.delete("SDKROOT")

    # MacVim doesn't have or require any Python package, so unset PYTHONPATH
    ENV.delete("PYTHONPATH")

    # make sure that CC is set to "clang"
    ENV.clang

    system "./configure", "--with-features=huge",
                          "--enable-multibyte",
                          "--with-macarchs=#{MacOS.preferred_arch}",
                          "--enable-perlinterp",
                          "--enable-rubyinterp",
                          "--enable-tclinterp",
                          "--enable-terminal",
                          "--with-tlib=ncurses",
                          "--with-compiledby=Homebrew",
                          "--with-local-dir=#{HOMEBREW_PREFIX}",
                          "--enable-cscope",
                          "--enable-luainterp",
                          "--with-lua-prefix=#{Formula["lua"].opt_prefix}",
                          "--enable-luainterp",
                          "--enable-python3interp",
                          "--disable-sparkle"
    system "make"

    prefix.install "src/MacVim/build/Release/MacVim.app"
    bin.install_symlink prefix/"MacVim.app/Contents/bin/mvim"

    # Create MacVim vimdiff, view, ex equivalents
    executables = %w[mvimdiff mview mvimex gvim gvimdiff gview gvimex]
    executables += %w[vi vim vimdiff view vimex]
    executables.each { |e| bin.install_symlink "mvim" => e }
  end

  test do
    output = shell_output("#{bin}/mvim --version")
    assert_match "+ruby", output

    # Simple test to check if MacVim was linked to Homebrew's Python 3
    py3_exec_prefix = Utils.popen_read("python3-config", "--exec-prefix")
    assert_match py3_exec_prefix.chomp, output
    (testpath/"commands.vim").write <<~EOS
      :python3 import vim; vim.current.buffer[0] = 'hello python3'
      :wq
    EOS
    system bin/"mvim", "-v", "-T", "dumb", "-s", "commands.vim", "test.txt"
    assert_equal "hello python3", (testpath/"test.txt").read.chomp
  end
end
