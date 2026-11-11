#!/usr/bin/env bash
# Git y GitHub CLI
source "$(dirname "$0")/../lib.sh"
say "Git y GitHub CLI"
have git || apt_install git
have gh  || apt_install gh

git --version
gh --version | head -1

echo
if [ -z "$(git config --global user.name)" ] || [ -z "$(git config --global user.email)" ]; then
  if ask "¿Configurar tu identidad de Git ahora?"; then
    read -rp "  Nombre:  " GN; read -rp "  Correo:  " GE
    git config --global user.name  "$GN"
    git config --global user.email "$GE"
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    note "Guardado en ~/.gitconfig"
  fi
else
  note "Identidad actual: $(git config --global user.name) <$(git config --global user.email)>"
fi

echo
if ! gh auth status >/dev/null 2>&1; then
  ask "¿Iniciar sesión en GitHub con gh auth login?" && gh auth login
else
  note "gh ya autenticado."
fi
