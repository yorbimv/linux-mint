#!/usr/bin/env bash
# Verificación final
source "$(dirname "$0")/../lib.sh"
say "Verificación final"
export DISPLAY="${DISPLAY:-:0}" XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

chk() { printf "  %-38s %s\n" "$1" "$2"; }

echo "Sistema"
chk "distribución"      "$(. /etc/os-release; echo "$PRETTY_NAME")"
chk "kernel"            "$(uname -r)"
chk "sesión"            "${XDG_SESSION_TYPE:-?} / ${XDG_CURRENT_DESKTOP:-?}"

echo
echo "Red"
chk "interfaz por defecto" "$(ip route get 1.1.1.1 2>/dev/null | sed -n 's/.*dev \([^ ]*\).*/\1/p')"
chk "IP"                   "$(hostname -I 2>/dev/null | awk '{print $1}')"
chk "driver wifi"          "$(lspci -k 2>/dev/null | grep -A2 -i wireless | grep 'Kernel driver' | head -1 | sed 's/.*: //')"
chk "internet"             "$(timeout 6 curl -sI https://example.com >/dev/null 2>&1 && echo OK || echo FALLA)"

echo
echo "Teclado"
chk "layout/variante"      "$(setxkbmap -query 2>/dev/null | awk '/^layout|^variant/{printf "%s ", $2}')"
chk "opciones"             "$(setxkbmap -query 2>/dev/null | sed -n 's/^options: *//p')"

echo
echo "Atajos"
chk "cerrar"               "$(gsettings get org.cinnamon.desktop.keybindings.wm close 2>/dev/null)"
chk "maximizar"            "$(gsettings get org.cinnamon.desktop.keybindings.wm toggle-maximized 2>/dev/null)"

echo
echo "Apps"
chk "brave"                "$(command -v brave-browser >/dev/null && brave-browser --version 2>/dev/null | head -1 || echo 'no instalado')"
chk "rustdesk"             "$(rustdesk --version 2>/dev/null | head -1 || echo 'no instalado')"
chk "rustdesk.service"     "$(systemctl is-active rustdesk.service 2>/dev/null || echo no)"
chk "git"                  "$(git --version 2>/dev/null || echo 'no instalado')"
