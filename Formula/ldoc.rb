class Ldoc < Formula
  desc "Documentation generator for Lua source code"
  homepage "https://lunarmodules.github.io/ldoc/"
  # The v1.5.0 release fails on Lua 5.5 (assigns to for-loop control variables, which
  # are const since 5.5); upstream master has the fixes but no release yet.
  url "https://github.com/lunarmodules/LDoc/archive/e1dff24e1c519c96bbf95647c9aeac2dfb3b9ae0.tar.gz"
  version "1.5.0-14-ge1dff24"
  sha256 "b64aa066e8d49c8e90cb14d8d5baa4d0e8810939a745e99e676ee72573404aa6"
  license "MIT"
  head "https://github.com/lunarmodules/LDoc.git", branch: "master"

  bottle do
    root_url "https://github.com/jbisfun/homebrew-tap/releases/download/ldoc-1.5.0-14-ge1dff24"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "50f9b289f8eee611b1bae9d4865c4b3714d1e510ac5ccd6a6e0c622812cf99f5"
    sha256 cellar: :any,                 x86_64_linux: "e7814968d8d74f1622543df387e0c2d8a9df309c95333124d9cefe6ef9c430d0"
  end

  depends_on "luarocks" => :build
  depends_on "lua"

  resource "luafilesystem" do
    url "https://github.com/lunarmodules/luafilesystem/archive/refs/tags/v1_9_0.tar.gz"
    sha256 "1142c1876e999b3e28d1c236bf21ffd9b023018e336ac25120fb5373aade1450"
  end

  resource "penlight" do
    url "https://github.com/lunarmodules/Penlight/archive/refs/tags/1.15.0.tar.gz"
    sha256 "b7a2c3e65799a649d29e9927a337f99cca2a5fc46367a0ce101435be74e53b39"
  end

  def install
    luarocks_args = %W[make --tree=#{libexec} --lua-dir=#{formula_opt_prefix("lua")} --deps-mode=none]
    resources.each do |r|
      r.stage { system "luarocks", *luarocks_args }
    end
    system "luarocks", *luarocks_args

    # luarocks' wrapper script already points package.path/cpath at the libexec tree.
    bin.install_symlink libexec/"bin/ldoc"
  end

  test do
    (testpath/"m.lua").write <<~LUA
      --- A test module.
      -- Uses `backticks` and *markdown*.
      -- @module m
      local M = {}

      --- Add two numbers.
      -- @tparam number a first
      -- @tparam number b second
      -- @treturn number the sum
      function M.add(a, b) return a + b end

      return M
    LUA
    system bin/"ldoc", "-f", "markdown", "-d", testpath/"out", testpath/"m.lua"
    assert_match "Add two numbers", (testpath/"out/index.html").read
    assert_match "<em>markdown</em>", (testpath/"out/index.html").read
  end
end
