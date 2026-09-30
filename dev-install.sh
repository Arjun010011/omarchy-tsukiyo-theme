#!/bin/bash
# Copy this folder into Omarchy's user themes and apply it.
#   ./dev-install.sh               everything, as it looks on this machine
#   ./dev-install.sh --as-installed  only what `omarchy theme install <url>` keeps
#                                    (no *.lua, terminal configs or vscode.json)
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
slug="$(cat "$here/theme.slug")"
target="$HOME/.config/omarchy/themes/$slug"

excludes=(--exclude .git --exclude .gitignore --exclude dev-install.sh
          --exclude theme.slug --exclude CLAUDE.md --exclude README.md --exclude LICENSE)
if [[ ${1:-} == --as-installed ]]; then
  excludes+=(--exclude '*.lua' --exclude alacritty.toml --exclude foot.ini
             --exclude ghostty.conf --exclude kitty.conf --exclude vscode.json)
fi

mkdir -p "$target"
rsync -a --delete "${excludes[@]}" "$here/" "$target/"
omarchy theme set "$slug"
echo "applied $slug from $target"
