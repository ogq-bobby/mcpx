# mcpx

Select MCP servers per session and launch a coding agent (Codex or Claude Code)
with only those servers enabled. MCP definitions are stored locally and never
written to the agent's global config.

## Features
- `mcpx add` stores MCP definitions under `~/.mcpx/servers/`
- `mcpx run` launches Codex or Claude with only the selected MCPs
- TUI selection via `gum` or `fzf`, with a plain prompt fallback
- Session-only overrides; nothing is persisted to `~/.codex/config.toml` or
  Claude config

## Requirements
- macOS with Bash (script is Bash 3.2 compatible)
- Optional: `gum` or `fzf` for nicer selection UI
- Codex CLI for `--agent codex`
- Claude Code CLI for `--agent claude`

## Install
```bash
./install.sh
```
This copies `mcpx` into your PATH (e.g. `/opt/homebrew/bin`). If `gum`
and `fzf` are missing and Homebrew is available, it will attempt to install
`gum` first, then `fzf`.

## Quick Start
Add an MCP server:
```bash
mcpx add youtube -- docker run --rm -i youtube-summary-mcp
```

Run with selection UI:
```bash
mcpx run
```

Run with Codex directly:
```bash
mcpx run --agent codex
```

Run with Claude Code directly:
```bash
mcpx run --agent claude
```

List or remove:
```bash
mcpx list
mcpx remove youtube
```

## Commands
```
mcpx add <name> -- <command> [args...]
mcpx add <name> --url <url> [--bearer-token-env-var ENV]
mcpx add <name> -- <command> [args...] [--env KEY=VALUE ...]
mcpx list
mcpx remove <name>
mcpx run [--agent codex|claude] [--all|--none] [--] [agent args...]
```

### add (stdio)
```bash
mcpx add slack -- npx slack-mcp-server
mcpx add my-mcp --env API_KEY=xxx -- my-mcp-bin --flag value
```

### add (http)
```bash
mcpx add sentry --url https://mcp.sentry.dev/mcp
```

## How MCPs are applied

### Codex
`mcpx` uses `codex -c 'mcp_servers={...}'` to override MCPs for the
current session only. No files are written.

### Claude Code
`mcpx` writes a temporary JSON file and runs:
```
claude --mcp-config <temp.json> --strict-mcp-config
```
The temp file is removed when the session ends.

## MCP storage format
Files are stored under:
```
~/.mcpx/servers/<name>.conf
```

Example:
```
TYPE=stdio
COMMAND=docker
ARG=run
ARG=--rm
ARG=-i
ARG=youtube-summary-mcp
ENV=API_KEY=xxx
```

## Environment
- `MCPX_HOME`: override the default config dir (`~/.mcpx`)

## Notes
- If you select nothing and choose Done, the session runs with no MCPs.
- For Claude Code, `BEARER_TOKEN_ENV_VAR` is ignored (Claude expects explicit
  headers/transport in its JSON config).
- If you installed `mcpx` via `install.sh`, rerun it after updates.
