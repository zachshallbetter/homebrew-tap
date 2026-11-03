# zachshallbetter/tap

Homebrew formulae for [Creative MCP](https://creativemcp.com): Model Context Protocol
servers that let AI assistants drive Adobe creative apps and Blender on your Mac.

Created and maintained by [Zach Shallbetter](https://zachshallbetter.com/) ·
[creativemcp.com](https://creativemcp.com) · [Docs](https://creativemcp.com/docs/)

## Install

```sh
brew tap zachshallbetter/tap
brew trust zachshallbetter/tap   # Homebrew 7+ asks you to trust third-party taps

# Adobe InDesign, Illustrator, Photoshop, Premiere Pro, After Effects
brew install zachshallbetter/tap/adobe-mcp

# Blender (no tagged release yet, so build from the main branch)
brew install --HEAD zachshallbetter/tap/blender-mcp
```

## What each formula installs

### `adobe-mcp`

Installs the [`adobe-mcp-suite`](https://www.npmjs.com/package/adobe-mcp-suite) npm package
(source: [zachshallbetter/adobe-mcp](https://github.com/zachshallbetter/adobe-mcp)) on Homebrew's
Node, and links these stdio MCP servers into `$(brew --prefix)/bin`:

| Command | Purpose |
| --- | --- |
| `adobe-mcp-suite` | Coordinator for cross-app workflows (e.g. place Illustrator artwork in InDesign) |
| `adobe-mcp-indesign` | Adobe InDesign server |
| `adobe-mcp-indesign-uxp-bridge` | HTTP + WebSocket bridge to the InDesign UXP plugin (ports 3000/3001) |
| `adobe-mcp-illustrator` | Adobe Illustrator server |
| `adobe-mcp-photoshop` | Adobe Photoshop server |
| `adobe-mcp-premiere` | Adobe Premiere Pro server |
| `adobe-mcp-aftereffects` | Adobe After Effects server |

The matching Adobe application must be installed and running when a tool is called.

### `blender-mcp`

Builds the `blender-mcp` CLI from [zachshallbetter/blender-mcp-rs](https://github.com/zachshallbetter/blender-mcp-rs)
with Cargo. It needs Blender 4.0 or newer plus its companion add-on, which the CLI installs:

```sh
blender-mcp addon install   # copy the add-on into every detected Blender version
blender-mcp addon status    # check which Blender versions have it
```

Then enable **Blender MCP** in Blender > Preferences > Add-ons.

## Register with an MCP client

Claude Code:

```sh
claude mcp add adobe-suite -- adobe-mcp-suite
claude mcp add indesign    -- adobe-mcp-indesign
blender-mcp client add claude-code      # also: cursor, codex, gemini, antigravity
```

Any client that takes a JSON config (Claude Desktop, Cursor, ...):

```json
{
  "mcpServers": {
    "adobe-suite": { "command": "/opt/homebrew/bin/adobe-mcp-suite" },
    "blender": { "command": "/opt/homebrew/bin/blender-mcp", "args": ["serve"] }
  }
}
```

Use the full path from `brew --prefix` (`/opt/homebrew` on Apple silicon, `/usr/local` on Intel)
because GUI apps often do not inherit your shell's `PATH`. `blender-mcp client generate-config <client>`
prints a ready-made snippet.

## Update

```sh
brew update
brew upgrade zachshallbetter/tap/adobe-mcp
brew upgrade --fetch-HEAD zachshallbetter/tap/blender-mcp   # HEAD builds only update with --fetch-HEAD
```

## Uninstall

```sh
blender-mcp addon status                 # note add-on paths if you want to remove them too
brew uninstall adobe-mcp blender-mcp
brew untap zachshallbetter/tap
```

Uninstalling does not remove the Blender add-on or entries you added to MCP client configs.

## Licenses

`adobe-mcp`: MIT. `blender-mcp`: MIT OR Apache-2.0.

## Author

Creative MCP, Adobe MCP and Blender MCP are created by [Zach Shallbetter](https://zachshallbetter.com/)
([GitHub](https://github.com/zachshallbetter) · [LinkedIn](https://linkedin.com/in/zachshallbetter)).
Learn more at [creativemcp.com/about](https://creativemcp.com/about.html).
