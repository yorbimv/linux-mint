#!/usr/bin/env bash
# Paquetes base del sistema
source "$(dirname "$0")/../lib.sh"
say "Paquetes base"
F="$REPO/paquetes/apt-base.txt"
[ -f "$F" ] || { warn "Falta $F"; exit 1; }
grep -vE '^\s*(#|$)' "$F" | sed 's/^/    /'
echo
ask "¿Instalar estos paquetes?" || { note "Omitido."; exit 2; }
mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$F")
apt_install "${PKGS[@]}"
ok "Paquetes base instalados."
