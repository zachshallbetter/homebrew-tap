class CreativeMcp < Formula
  desc "Detects creative apps and MCP clients, then installs Creative MCP servers"
  homepage "https://creativemcp.com/docs/architecture.html#installer"
  url "https://github.com/zachshallbetter/creative-mcp/archive/refs/tags/cli-v0.1.0.tar.gz"
  version "0.1.0"
  sha256 "6a8d18a454da04205b43ef8b94675146044ef8bd3e8f604ba34e9d241a7e7a7f"
  license "MIT"
  head "https://github.com/zachshallbetter/creative-mcp.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "cli")
  end

  def caveats
    <<~EOS
      Set up the Creative MCP servers that match the apps on this machine:
        creative-mcp setup

      It shows every command and config change before making it. Preview without changes:
        creative-mcp setup --dry-run
    EOS
  end

  test do
    assert_match "creative-mcp #{version}", shell_output("#{bin}/creative-mcp --version")
    catalogue = JSON.parse(shell_output("#{bin}/creative-mcp list --json"))
    ids = catalogue["tools"].map { |t| t["id"] }
    assert_includes ids, "adobe"
    assert_includes ids, "blender"
    assert_match "Detect apps and MCP clients", shell_output("#{bin}/creative-mcp help")
  end
end
