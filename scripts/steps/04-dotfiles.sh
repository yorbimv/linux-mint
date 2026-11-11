#!/usr/bin/env bash
# Dotfiles: enlazar config de bash, git, OpenCode
source "$(dirname "$0")/../lib.sh"
say "Dotfiles"
D="$REPO/dotfiles"
while IFS='|' read -r label src dst; do
  echo; echo "• $label"; note "$dst -> $src"
  ask "  ¿Enlazar?" && link "$src" "$dst"
done <<LIST
Bash (.bashrc)|$D/bash/.bashrc|$HOME/.bashrc
Bash (.profile)|$D/bash/.profile|$HOME/.profile
OpenCode|$D/opencode/opencode.json|$HOME/.config/opencode/opencode.json
LIST

echo
note "Cinnamon y RustDesk se enlazan en sus pasos (08 y 10)."
