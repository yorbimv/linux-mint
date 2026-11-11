#!/usr/bin/env bash
# Selector del gesto de clic derecho para el trackpad del MacBook (bcm5974).
# No necesita sudo: aplica gsettings (persistente) + xinput (en caliente).
set -uo pipefail

export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

T=org.cinnamon.desktop.peripherals.touchpad
DEV="$(xinput list --name-only 2>/dev/null | grep -m1 -iE "bcm5974|trackpad" || true)"

opcion="$(zenity --list --title="Clic derecho del trackpad" \
    --text="Elige el gesto para el clic derecho:" \
    --column="Modo" --width=420 --height=220 \
    "Dos dedos (estilo Mac)" \
    "Esquina inferior derecha" 2>/dev/null)" || exit 0

case "$opcion" in
    "Dos dedos (estilo Mac)")
        gsettings set "$T" click-method 'fingers'
        gsettings set "$T" tap-to-click true
        gsettings set "$T" tap-and-drag true
        if [ -n "$DEV" ]; then
            xinput set-prop "$DEV" "libinput Click Method Enabled" 0 1 2>/dev/null || true
            xinput set-prop "$DEV" "libinput Tapping Enabled" 1 2>/dev/null || true
            xinput set-prop "$DEV" "libinput Tapping Button Mapping Enabled" 1 0 2>/dev/null || true
        fi
        MSG="Activado: 2 dedos tocando = clic derecho, 2 dedos pulsando = clic derecho, 3 dedos = botón central."
        ;;
    "Esquina inferior derecha")
        gsettings set "$T" click-method 'areas'
        if [ -n "$DEV" ]; then
            xinput set-prop "$DEV" "libinput Click Method Enabled" 1 0 2>/dev/null || true
        fi
        MSG="Activado: la esquina inferior derecha del trackpad = clic derecho."
        ;;
    *) exit 0 ;;
esac

zenity --info --title="Trackpad" --text="$MSG" --width=420 2>/dev/null || echo "$MSG"
