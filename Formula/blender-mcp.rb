class BlenderMcp < Formula
  desc "Rust-native Model Context Protocol server and spatial agent engine for Blender"
  homepage "https://creativemcp.com/docs/implementations/blender.html"
  url "https://github.com/zachshallbetter/blender-mcp-rs/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "31775853b32c7358c9f2f32bf503331b4457b245fbc5939f428353eae3ad0ba4"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/zachshallbetter/blender-mcp-rs.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/blender-mcp-cli")
  end

  def caveats
    <<~EOS
      blender-mcp needs Blender 4.0 or newer and its companion add-on, which the
      server talks to over a local socket (127.0.0.1:9876 by default).

      Install the add-on into every detected Blender version:
        blender-mcp addon install
      then enable "Blender MCP" in Blender > Preferences > Add-ons.

      Register the server with your MCP client, e.g.:
        blender-mcp client add claude-code
      (also: cursor, codex, gemini, antigravity; see `blender-mcp client list`)
    EOS
  end

  test do
    assert_match(/^blender-mcp \d+\.\d+\.\d+/, shell_output("#{bin}/blender-mcp --version"))

    # Generating a client snippet is offline and must point back at `blender-mcp serve`.
    config = shell_output("#{bin}/blender-mcp client generate-config claude-code")
    assert_match "blender-mcp", config
    assert_match "serve", config

    # With no Blender installed under the test HOME, add-on status still runs cleanly.
    system bin/"blender-mcp", "addon", "status"
  end
end
