#!/usr/bin/env bash
# Trackpad: clic derecho con dos dedos
source "$(dirname "$0")/../lib.sh"
say "Trackpad (clic derecho con dos dedos)"
export DISPLAY="${DISPLAY:-:0}" XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
ask "¿Aplicar clic derecho a dos dedos?" || { note "Omitido."; exit 2; }
bash "$REPO/scripts/hardware/trackpad.sh"
