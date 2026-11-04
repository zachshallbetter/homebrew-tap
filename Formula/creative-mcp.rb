class CreativeMcp < Formula
  desc "Detects creative apps and MCP clients, then installs Creative MCP servers"
  homepage "https://creativemcp.com/docs/architecture.html#installer"
  url "https://github.com/zachshallbetter/creative-mcp/archive/refs/tags/cli-v0.2.2.tar.gz"
  sha256 "79e08bc7703881b006228dad0515103a35275ac95f57d2a683752480438ec652"
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

      Afterwards: creative-mcp doctor checks everything, creative-mcp update keeps it current.
    EOS
  end

  test do
    assert_match "creative-mcp #{version}", shell_output("#{bin}/creative-mcp --version")
    catalogue = JSON.parse(shell_output("#{bin}/creative-mcp list --json"))
    ids = catalogue["tools"].map { |t| t["id"] }
    assert_includes ids, "adobe"
    assert_includes ids, "blender"
    assert_match "Detect apps and MCP clients", shell_output("#{bin}/creative-mcp help")
    assert_match "creative-mcp remove", shell_output("#{bin}/creative-mcp remove 2>&1", 2)
  end
end
