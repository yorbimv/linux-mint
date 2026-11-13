#!/usr/bin/env bash
# Cinnamon: atajos estilo macOS y preferencias
source "$(dirname "$0")/../lib.sh"
say "Cinnamon: atajos y preferencias"
export DISPLAY="${DISPLAY:-:0}" XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

echo
note "Atajos: toque de ⌘ abre el menú · ⌘Q cerrar · ⌘M/⌘H minimizar · ⌘⇧M maximizar · ⌘Tab cambiar · ⌘←/→ media pantalla · Ctrl+←/→ escritorio · Ctrl+Shift+←/→ mover ventana"
ask "¿Aplicar los atajos estilo macOS?" && bash "$REPO/dotfiles/cinnamon/atajos-mac.sh"

echo
if [ -f "$REPO/dotfiles/cinnamon/dconf-cinnamon.ini" ]; then
  note "También hay un volcado completo de Cinnamon (temas, panel, applets, fondo)."
  warn "Cargarlo REEMPLAZA la configuración actual de Cinnamon."
  if ask "¿Restaurar ese volcado encima (se guarda copia antes)?"; then
    mkdir -p "$HOME/.config/dconf-backups"
    dconf dump /org/cinnamon/ > "$HOME/.config/dconf-backups/cinnamon-$STAMP.ini"
    dconf load /org/cinnamon/ < "$REPO/dotfiles/cinnamon/dconf-cinnamon.ini"
    note "Copia previa: ~/.config/dconf-backups/cinnamon-$STAMP.ini"
    note "Reinicia Cinnamon:  cinnamon --replace &"
  fi
fi
