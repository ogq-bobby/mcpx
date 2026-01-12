#!/usr/bin/env bash
set -euo pipefail

die() {
  echo "install.sh: $*" >&2
  exit 1
}

warn() {
  echo "install.sh: $*" >&2
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$script_dir/mcp-switch"

[[ -f "$src" ]] || die "mcp-switch not found at $src"

choose_bindir() {
  local d
  for d in /opt/homebrew/bin /usr/local/bin; do
    if [[ -d "$d" && -w "$d" ]]; then
      printf '%s' "$d"
      return 0
    fi
  done
  printf '%s' "$HOME/.local/bin"
}

install_tui() {
  if command -v gum >/dev/null 2>&1 || command -v fzf >/dev/null 2>&1; then
    return 0
  fi
  if command -v brew >/dev/null 2>&1; then
    echo "Installing gum (for TUI selection)..."
    if brew install gum >/dev/null; then
      return 0
    fi
    warn "gum install failed; trying fzf..."
    if brew install fzf >/dev/null; then
      return 0
    fi
    warn "Failed to install gum/fzf; mcp-switch will fall back to prompts."
    return 0
  fi
  warn "gum/fzf not found and Homebrew is not installed."
  warn "Install gum or fzf for TUI selection; otherwise prompts will be used."
}

bindir="$(choose_bindir)"
mkdir -p "$bindir"

cp "$src" "$bindir/mcp-switch"
chmod +x "$bindir/mcp-switch"

install_tui

echo "Installed mcp-switch to $bindir/mcp-switch"

if ! echo ":$PATH:" | grep -q ":$bindir:"; then
  echo "Add $bindir to PATH to use mcp-switch globally."
  echo "Example: echo 'export PATH=\"$bindir:\$PATH\"' >> ~/.zshrc"
fi
