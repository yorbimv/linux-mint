#!/usr/bin/env bash
# Aplicaciones: Brave, Firefox, VS Code y utilidades
source "$(dirname "$0")/../lib.sh"
say "Aplicaciones"
F="$REPO/paquetes/apt-extra.txt"

echo "• Brave Browser (repositorio oficial, se actualiza con apt)"
ask "  ¿Instalar Brave?" && sudo bash "$REPO/scripts/apps/brave.sh"

echo
echo "• Visual Studio Code estable (repositorio oficial de Microsoft)"
ask "  ¿Instalar VS Code?" && sudo bash "$REPO/scripts/apps/vscode.sh"

echo
echo "• Firefox + locales en español"
ask "  ¿Instalar/actualizar Firefox y sus locales?" && apt_install firefox firefox-locale-es firefox-locale-en

echo
echo "• Visor de cámara guvcview (en ~/.local, sin sudo)"
ask "  ¿Instalar guvcview y v4l-utils?" && bash "$REPO/scripts/apps/guvcview.sh"

echo
[ -f "$F" ] && note "Otras apps en paquetes/apt-extra.txt:"
[ -f "$F" ] && grep -vE '^\s*(#|$)' "$F" | sed 's/^/    /'
[ -f "$F" ] && ask "  ¿Instalar esas utilidades?" && apt_install $(grep -vE '^\s*(#|$)' "$F" | tr '\n' ' ')

echo
if have flatpak; then
  note "Flatpak disponible. Apps flatpak del repo en paquetes/flatpak.txt"
fi
ok "Aplicaciones listas."
