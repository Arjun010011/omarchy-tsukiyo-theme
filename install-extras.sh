#!/bin/bash
# Tsukiyo extras: apps Omarchy does not theme on its own.
#   ./install-extras.sh            install (each replaced file is backed up once)
#   ./install-extras.sh --remove   restore the backups
#
# Touches only colour/look files: GTK, starship, fastfetch, lazygit, yazi, cava, tmux,
# fish, Zed, opencode, Zen browser,
# the bar and clock (patched clones), the Dynamic Island plugin, and the lock screen (a clone of
# omarchy.lock whose LockView.qml is replaced).
# It never installs packages and never changes the cursor or icon theme.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
extras="$here/extras"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
tag="pre-tsukiyo"

say() { printf '  \e[38;2;136;164;173m›\e[0m %s\n' "$1"; }
dim() { printf '  \e[38;2;74;90;99m· %s\e[0m\n' "$1"; }

# place <source> <target>: back the target up once, then copy the source over it
place() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst && ! -e $dst.$tag ]] && ! cmp -s "$src" "$dst"; then
    cp -a "$dst" "$dst.$tag"
  fi
  cp "$src" "$dst"
  say "${dst/#$HOME/\~}"
}

restore() {
  local dst="$1"
  if [[ -e $dst.$tag ]]; then
    mv -f "$dst.$tag" "$dst"
    say "restored ${dst/#$HOME/\~}"
  fi
}

# backup <file>: keep the original once before editing a user's own config in place
backup() { [[ -e $1 && ! -e $1.$tag ]] && cp -a "$1" "$1.$tag"; return 0; }

targets=(
  "$cfg/hypr/hyprland.lua"
  "$cfg/fish/conf.d/tsukiyo.fish"
  "$cfg/fish/conf.d/zz-tsukiyo-tide.fish"
  "$cfg/zed/themes/tsukiyo.json"
  "$cfg/zed/settings.json"
  "$cfg/opencode/themes/tsukiyo.json"
  "$cfg/opencode/tui.json"
  "$cfg/tmux/tmux.conf"
  "$cfg/cava/config"
  "$cfg/gtk-3.0/gtk.css"
  "$cfg/gtk-4.0/gtk.css"
  "$cfg/starship.toml"
  "$cfg/fastfetch/config.jsonc"
  "$cfg/fastfetch/tsukiyo-logo.txt"
  "$cfg/yazi/theme.toml"
  "$cfg/cava/themes/tsukiyo"
  "$cfg/tmux/tsukiyo.conf"
)

if [[ ${1:-} == --remove ]]; then
  for t in "${targets[@]}"; do restore "$t"; done
  restore "$cfg/lazygit/config.yml"
  restore "$cfg/omarchy/plugins/$USER.lock/LockView.qml"
  restore "$cfg/omarchy/plugins/$USER.bar/Bar.qml"
  restore "$cfg/omarchy/plugins/$USER.clock/BarWidget.qml"
  for w in network bluetooth audio power monitor; do restore "$cfg/omarchy/plugins/$USER.$w/Panel.qml"; done
  for zen_root in "$HOME/.config/zen" "$HOME/.zen"; do
    [[ -f $zen_root/profiles.ini ]] || continue
    while IFS= read -r rel; do
      for f in userChrome.css userContent.css; do
        cf="$zen_root/$rel/chrome/$f"
        [[ -f $cf ]] && sed -i '/tsukiyo/d' "$cf" && say "cleaned ${cf/#$HOME/\~}"
      done
    done < <(sed -n 's/^Path=//p' "$zen_root/profiles.ini")
  done
  rm -f "$cfg/hypr/tsukiyo.lua" "$cfg/nvim/lua/plugins/tsukiyo.lua"
  rm -f "$cfg/fish/conf.d/tsukiyo.fish" "$cfg/fish/conf.d/zz-tsukiyo-tide.fish"
  sed -i '/tsukiyo/d;/^# Tsukiyo$/d' "$cfg/tmux/tmux.conf" 2>/dev/null || true
  exit 0
fi

echo
printf '  \e[38;2;200;196;187mTsukiyo\e[0m \e[38;2;74;90;99mextras\e[0m\n\n'

place "$extras/gtk.css" "$cfg/gtk-3.0/gtk.css"
place "$extras/gtk.css" "$cfg/gtk-4.0/gtk.css"

command -v starship >/dev/null && place "$extras/starship.toml" "$cfg/starship.toml" || dim "starship not installed"

if command -v fastfetch >/dev/null; then
  place "$extras/fastfetch/config.jsonc" "$cfg/fastfetch/config.jsonc"
  place "$extras/fastfetch/logo.txt" "$cfg/fastfetch/tsukiyo-logo.txt"
else
  dim "fastfetch not installed"
fi

command -v yazi >/dev/null && place "$extras/yazi-theme.toml" "$cfg/yazi/theme.toml" || dim "yazi not installed"

if command -v cava >/dev/null; then
  place "$extras/cava-theme" "$cfg/cava/themes/tsukiyo"
else
  dim "cava not installed"
fi

if command -v tmux >/dev/null; then
  place "$extras/tmux.conf" "$cfg/tmux/tsukiyo.conf"
fi

# Hyprland motion and Neovim colours: a GitHub install drops the theme's .lua files,
# so load them from the installed theme while Tsukiyo is active.
if [[ -f $cfg/hypr/hyprland.lua ]]; then
  place "$extras/hypr/tsukiyo.lua" "$cfg/hypr/tsukiyo.lua"
  hl="$cfg/hypr/hyprland.lua"
  if ! grep -q 'require("hypr.tsukiyo")' "$hl"; then
    backup "$hl"
    if grep -q '^require("default.hypr.omarchy")' "$hl"; then
      sed -i '/^require("default.hypr.omarchy")/a require("hypr.tsukiyo") -- Tsukiyo theme motion (install-extras.sh)' "$hl"
    else
      printf '\nrequire("hypr.tsukiyo") -- Tsukiyo theme motion (install-extras.sh)\n' >>"$hl"
    fi
    say "${hl/#$HOME/\~} (loads hypr/tsukiyo.lua)"
  fi
  hyprctl reload >/dev/null 2>&1 || true
fi
if [[ -d $cfg/nvim/lua/plugins ]]; then
  place "$extras/nvim/tsukiyo.lua" "$cfg/nvim/lua/plugins/tsukiyo.lua"
fi

# fish: syntax, autosuggestion and pager colours
if command -v fish >/dev/null; then
  place "$extras/fish/tsukiyo.fish" "$cfg/fish/conf.d/tsukiyo.fish"
  place "$extras/fish/zz-tsukiyo-tide.fish" "$cfg/fish/conf.d/zz-tsukiyo-tide.fish"
fi

# Zed: install the theme and select it for dark mode
if [[ -d $cfg/zed ]]; then
  place "$extras/zed/tsukiyo.json" "$cfg/zed/themes/tsukiyo.json"
  zs="$cfg/zed/settings.json"
  [[ -f $zs ]] || echo '{}' >"$zs"
  backup "$zs"
  python3 - "$zs" <<'PY'
import re, sys
p = sys.argv[1]; s = open(p).read()
block = re.search(r'"theme"\s*:\s*\{[^{}]*\}', s)
if block:
    inner = block.group(0)
    new = re.sub(r'"dark"\s*:\s*"[^"]*"', '"dark": "Tsukiyo"', inner)
    if '"dark"' not in new:
        new = new[:-1].rstrip().rstrip(',') + ',\n    "dark": "Tsukiyo"\n  }'
    s = s.replace(inner, new)
elif re.search(r'"theme"\s*:\s*"[^"]*"', s):
    s = re.sub(r'"theme"\s*:\s*"[^"]*"', '"theme": "Tsukiyo"', s, count=1)
else:
    s = re.sub(r'\{', '{\n  "theme": "Tsukiyo",', s, count=1)
open(p, "w").write(s)
PY
  say "${zs/#$HOME/\~} (theme)"
fi

# opencode: install the theme and select it
if [[ -d $cfg/opencode ]]; then
  place "$extras/opencode/tsukiyo.json" "$cfg/opencode/themes/tsukiyo.json"
  tui="$cfg/opencode/tui.json"
  [[ -f $tui ]] || echo '{"$schema": "https://opencode.ai/tui.json"}' >"$tui"
  backup "$tui"
  python3 - "$tui" <<'PY'
import json, sys
p = sys.argv[1]; d = json.load(open(p)); d["theme"] = "tsukiyo"
open(p, "w").write(json.dumps(d, indent=2) + "\n")
PY
  say "${tui/#$HOME/\~} (theme)"
fi

# Zen browser: import the theme from userChrome/userContent in every profile
for zen_root in "$HOME/.config/zen" "$HOME/.zen"; do
  [[ -f $zen_root/profiles.ini ]] || continue
  while IFS= read -r rel; do
    prof="$zen_root/$rel"
    [[ -d $prof ]] || continue
    mkdir -p "$prof/chrome"
    cp "$extras/zen/tsukiyo.css" "$prof/chrome/tsukiyo.css"
    cp "$extras/zen/tsukiyo-content.css" "$prof/chrome/tsukiyo-content.css"
    for pair in "userChrome.css:tsukiyo.css" "userContent.css:tsukiyo-content.css"; do
      f="$prof/chrome/${pair%%:*}"; imp="@import url(\"${pair##*:}\");"
      touch "$f"
      grep -qF "$imp" "$f" || { backup "$f"; printf '%s\n%s' "$imp" "$(cat "$f")" >"$f"; }
    done
    grep -q legacyUserProfileCustomizations "$prof/user.js" 2>/dev/null ||
      echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >>"$prof/user.js"
    say "${prof/#$HOME/\~} (restart Zen)"
  done < <(sed -n 's/^Path=//p' "$zen_root/profiles.ini")
done

# tmux: source the theme last so it wins over earlier colour settings
if command -v tmux >/dev/null; then
  tc="$cfg/tmux/tmux.conf"; [[ -f $tc ]] || tc="$HOME/.tmux.conf"
  line="source-file $cfg/tmux/tsukiyo.conf"
  if [[ -f $tc ]] && ! grep -qF "$line" "$tc"; then
    backup "$tc"; printf '\n# Tsukiyo\n%s\n' "$line" >>"$tc"
    say "${tc/#$HOME/\~} (sources tsukiyo.conf)"
    tmux source-file "$tc" 2>/dev/null || true
  fi
fi

# cava: write the gradient straight into [color]
cc="$cfg/cava/config"
if command -v cava >/dev/null && [[ -f $cc ]] && ! grep -q "tsukiyo begin" "$cc"; then
  backup "$cc"
  python3 - "$cc" "$extras/cava-theme" <<'PY'
import sys
cfg, theme = sys.argv[1], sys.argv[2]
lines = [l for l in open(theme).read().splitlines() if l and not l.startswith(("#", "["))]
block = "# tsukiyo begin\n" + "\n".join(lines) + "\n# tsukiyo end\n"
s = open(cfg).read()
s = s.replace("[color]\n", "[color]\n" + block, 1) if "[color]\n" in s else s + "\n[color]\n" + block
open(cfg, "w").write(s)
PY
  say "${cc/#$HOME/\~} (gradient)"
fi

# lazygit: merge the gui.theme block instead of replacing the user's config
if command -v lazygit >/dev/null; then
  lg="$cfg/lazygit/config.yml"
  mkdir -p "$(dirname "$lg")"
  touch "$lg"
  [[ -e $lg.$tag ]] || cp -a "$lg" "$lg.$tag"
  python3 - "$lg" "$extras/lazygit.yml" <<'PY'
import sys, re
target, theme = sys.argv[1], sys.argv[2]
text = open(target).read()
block = open(theme).read().split("\n", 1)[1]  # drop the comment line
# Remove an existing top-level gui: block, then append ours.
text = re.sub(r"(?ms)^gui:\n(?:[ \t]+.*\n?|\n)*", "", text).rstrip()
open(target, "w").write((text + "\n\n" if text else "") + block)
PY
  say "${lg/#$HOME/\~} (gui block)"
fi

# Bar and clock: clone the stock plugins once, then apply small patches (a
# floating frosted slab, serif type, and a lock-screen style clock). Patching
# instead of shipping copies keeps every other part of the bar Omarchy's own.
shell_patch() {
  local source_id="$1" file="$2" patch_file="$3"
  local dir="$cfg/omarchy/plugins/$USER.${source_id#omarchy.}"
  [[ -d $dir ]] || omarchy plugin clone "$source_id" >/dev/null
  if [[ ! -f $dir/$file ]]; then
    dim "could not clone $source_id"
  elif grep -q "Tsukiyo" "$dir/$file"; then
    dim "${dir/#$HOME/\~}/$file already patched"
  elif patch --dry-run -s "$dir/$file" "$patch_file" >/dev/null; then
    [[ -e $dir/$file.$tag ]] || cp -a "$dir/$file" "$dir/$file.$tag"
    patch -s "$dir/$file" "$patch_file"
    say "${dir/#$HOME/\~}/$file"
  else
    dim "$source_id changed upstream; patch skipped"
  fi
}

if command -v omarchy >/dev/null; then
  shell_patch omarchy.bar Bar.qml "$extras/shell/bar.patch"
  shell_patch omarchy.clock BarWidget.qml "$extras/shell/clock.patch"
  # Hairline icons: each status widget keeps its logic and draws MistIcon.
  for w in network bluetooth audio power monitor; do
    shell_patch "omarchy.$w" Panel.qml "$extras/shell/$w.patch"
    [[ -d $cfg/omarchy/plugins/$USER.$w ]] && cp "$extras/shell/MistIcon.qml" "$cfg/omarchy/plugins/$USER.$w/MistIcon.qml"
  done
  omarchy restart shell >/dev/null 2>&1 || true
  jq_center='(.bar.centerAnchor) |= (if . == "omarchy.clock" then env.USER + ".clock" else . end)'
  if command -v jq >/dev/null && [[ -f $cfg/omarchy/shell.json ]]; then
    tmp=$(mktemp); jq "$jq_center" "$cfg/omarchy/shell.json" >"$tmp" && mv "$tmp" "$cfg/omarchy/shell.json"
  fi
fi

# Dynamic Island: the author's companion plugin (music, notifications, timers and
# system popups in a notch), drawn in the theme's colours. Omarchy asks once
# before cloning it; the plugin takes over notifications and hands them back if
# it is ever disabled or removed.
island_url="https://github.com/Arjun010011/omarchy-dynamic-island"
if command -v omarchy >/dev/null; then
  if omarchy plugin list 2>/dev/null | grep -q '^omarchy-dynamic-island '; then
    dim "dynamic island already installed"
  elif omarchy plugin add "$island_url" --enable; then
    say "dynamic island (omarchy-dynamic-island)"
  else
    dim "dynamic island skipped; add it later with: omarchy plugin add $island_url --enable"
  fi
fi

# Lock screen: clone the stock lock plugin once, then swap in the Tsukiyo view.
# Service.qml (password and fingerprint handling) stays Omarchy's own.
if command -v omarchy >/dev/null; then
  lock_dir="$cfg/omarchy/plugins/$USER.lock"
  if [[ ! -d $lock_dir ]]; then
    omarchy plugin clone omarchy.lock >/dev/null
  fi
  if [[ -f $lock_dir/LockView.qml ]]; then
    place "$extras/lock/LockView.qml" "$lock_dir/LockView.qml"
    omarchy restart shell >/dev/null 2>&1 || true
    dim "lock screen: preview it with  omarchy-shell lock preview  (click to close)"
  else
    dim "lock screen: could not clone omarchy.lock"
  fi
fi

echo
dim "undo with ./install-extras.sh --remove"
echo
