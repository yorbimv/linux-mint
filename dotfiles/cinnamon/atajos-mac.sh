#!/usr/bin/env bash
# Atajos de ventana estilo macOS para Cinnamon.
# La tecla Cmd del MacBook es ahora Control (opcion ctrl:swap_lwin_lctl),
# por eso "Cmd+X" se escribe en Cinnamon como "<Control>x".
#
#   ./atajos-mac.sh            aplica los atajos estilo Mac
#   ./atajos-mac.sh --revertir vuelve a los valores originales de Cinnamon
set -uo pipefail

export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

WM=org.cinnamon.desktop.keybindings.wm
MODO="${1:-aplicar}"

if [[ "$MODO" == "--revertir" ]]; then
    gsettings set $WM close                     "['<Alt>F4']"
    gsettings set $WM minimize                  "@as []"
    gsettings set $WM switch-windows            "['<Alt>Tab']"
    gsettings set $WM switch-windows-backward   "['<Shift><Alt>Tab']"
    gsettings set $WM push-tile-left            "['<Super>Left']"
    gsettings set $WM push-tile-right           "['<Super>Right']"
    gsettings set $WM toggle-maximized          "['<Alt>F10']"
    echo "Atajos de ventana restaurados a los valores originales de Cinnamon."
else
    # Cmd+Q cerrar ventana
    gsettings set $WM close                     "['<Control>q','<Alt>F4']"
    # Cmd+M minimizar / Cmd+H ocultar (minimizar)
    gsettings set $WM minimize                  "['<Control>m','<Control>h']"
    # Cmd+Tab cambiar de ventana (Alt+Tab dejo de funcionar al ser Option = AltGr)
    gsettings set $WM switch-windows            "['<Control>Tab','<Super>Tab']"
    gsettings set $WM switch-windows-backward   "['<Shift><Control>Tab','<Shift><Super>Tab']"
    # Cmd+flechas llevar la ventana a media pantalla
    gsettings set $WM push-tile-left            "['<Control>Left','<Super>Left']"
    gsettings set $WM push-tile-right           "['<Control>Right','<Super>Right']"
    # Cmd+Shift+M maximizar / restaurar
    gsettings set $WM toggle-maximized          "['<Shift><Control>m','<Alt>F10']"
    echo "Atajos estilo macOS aplicados:"
    echo "  Cmd+Q        cerrar ventana"
    echo "  Cmd+M / Cmd+H minimizar"
    echo "  Cmd+Shift+M  maximizar / restaurar"
    echo "  Cmd+Tab      cambiar de ventana (Shift+Cmd+Tab al reves)"
    echo "  Cmd+Izq/Der  ventana a la mitad izquierda/derecha"
fi

echo
echo "Valores actuales:"
for k in close minimize toggle-maximized switch-windows switch-windows-backward push-tile-left push-tile-right; do
    printf "  %-24s %s\n" "$k" "$(gsettings get $WM $k)"
done
