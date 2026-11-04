class BlenderMcp < Formula
  desc "Rust-native Model Context Protocol server and spatial agent engine for Blender"
  homepage "https://creativemcp.com/docs/implementations/blender.html"
  url "https://github.com/zachshallbetter/blender-mcp-rs/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "6cc19c3c20d8e1023687d84041d39430fea0d0126bb370de1abf19cb0bccfef8"
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

      Install and turn on the add-on for every Blender version (quit Blender first):
        blender-mcp addon install

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
