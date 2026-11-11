#!/usr/bin/env bash
# Teclado Mac español (variante es(mac))
source "$(dirname "$0")/../lib.sh"
say "Teclado Mac español → variante es(mac)"
note "Reconstruye el mapa del Apple Spanish ISO, lo registra en el menú y lo"
note "deja activo con: es + mac, Cmd→Ctrl y Option = AltGr."
ask "¿Instalar la variante ahora?" || { note "Omitido."; exit 2; }
sudo bash "$REPO/scripts/hardware/wifi-helper/instalar-teclado-mac.sh"

echo
# Aplicar en la sesión actual (X11)
if [ -n "${DISPLAY:-}" ] || [ -S /tmp/.X11-unix/X0 ]; then
  export DISPLAY="${DISPLAY:-:0}" XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
  setxkbmap -layout es -variant mac \
    -option terminate:ctrl_alt_bksp -option ctrl:swap_lwin_lctl 2>/dev/null \
    && ok "Aplicado en la sesión actual." || note "Se aplicará al cerrar sesión."
fi
note "La variante se pierde si se actualiza xkb-data: vuelve a ejecutar este paso."
