class AdobeMcp < Formula
  desc "MCP servers for Adobe InDesign, Illustrator, Photoshop, Premiere, After Effects"
  homepage "https://creativemcp.com/apps.html"
  url "https://registry.npmjs.org/adobe-mcp-suite/-/adobe-mcp-suite-0.3.0.tgz"
  sha256 "ef74a2a5d073f3411a715d7b73d9c3e1fb3e801bd7e9fb6a3752ff54f8906e03"
  license "MIT"

  depends_on "node"

  # Executables shipped by the suite's per-application dependencies.
  APP_BINS = %w[
    adobe-mcp-indesign
    adobe-mcp-indesign-uxp-bridge
    adobe-mcp-illustrator
    adobe-mcp-photoshop
    adobe-mcp-premiere
    adobe-mcp-aftereffects
  ].freeze

  def install
    system "npm", "install", *std_npm_args
    # The coordinator (adobe-mcp-suite) is linked by std_npm_args into libexec/bin.
    bin.install_symlink libexec.glob("bin/*")

    # Expose each application server too, so clients can register just one app.
    node_bin = libexec/"lib/node_modules/adobe-mcp-suite/node_modules/.bin"
    APP_BINS.each do |name|
      bin.install_symlink node_bin/name
    end
  end

  def caveats
    <<~EOS
      These are stdio MCP servers. Register the one(s) you need with your MCP client, e.g.:
        claude mcp add adobe-suite -- #{opt_bin}/adobe-mcp-suite
        claude mcp add indesign    -- #{opt_bin}/adobe-mcp-indesign

      The matching Adobe application must be installed and running for tool calls to work.
    EOS
  end

  test do
    require "open3"
    require "timeout"

    request = {
      jsonrpc: "2.0",
      id:      1,
      method:  "initialize",
      params:  {
        protocolVersion: "2025-06-18",
        capabilities:    {},
        clientInfo:      { name: "homebrew-test", version: "1.0" },
      },
    }.to_json

    %w[
      adobe-mcp-suite
      adobe-mcp-indesign
      adobe-mcp-illustrator
      adobe-mcp-photoshop
      adobe-mcp-premiere
      adobe-mcp-aftereffects
    ].each do |server|
      Open3.popen3(bin/server) do |stdin, stdout, _stderr, wait_thr|
        stdin.puts request
        stdin.flush
        line = Timeout.timeout(30) { stdout.gets }
        refute_nil line, "#{server} produced no output"
        response = JSON.parse(line)
        assert_equal 1, response["id"]
        server_info = response.dig("result", "serverInfo")
        refute_nil server_info, "#{server}: #{line}"
        assert_equal version.to_s, server_info["version"] if server == "adobe-mcp-suite"
      ensure
        stdin.close unless stdin.closed?
        begin
          Process.kill("TERM", wait_thr.pid)
        rescue Errno::ESRCH
          nil
        end
      end
    end

    assert_path_exists bin/"adobe-mcp-indesign-uxp-bridge"
  end
end
