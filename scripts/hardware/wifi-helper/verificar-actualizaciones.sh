#!/usr/bin/env bash
# Verifica el estado de actualizaciones del sistema (no instala nada).
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -eq 0 ]] || { echo "ERROR: requiere root"; exit 1; }

echo "== 1. Actualizando índices de paquetes =="
apt-get -o DPkg::Lock::Timeout=600 update 2>&1 | tail -3

echo; echo "== 2. Paquetes con actualización disponible =="
UPG="$(apt list --upgradable 2>/dev/null | sed -n '2,$p')"
if [ -z "$UPG" ]; then echo "  (ninguno)"; else echo "$UPG"; fi
COUNT=$(printf '%s' "$UPG" | grep -c . || true)
echo "  TOTAL_UPGRADABLE=$COUNT"

echo; echo "== 3. Simulación de actualización completa (dist-upgrade) =="
apt-get -s -o DPkg::Lock::Timeout=600 dist-upgrade 2>/dev/null \
    | grep -E "^(Inst|Conf|Remv) " | sed 's/^/  /' | head -60

echo; echo "== 4. Paquetes rotos o a medio configurar (dpkg --audit) =="
if dpkg --audit 2>&1 | grep -q .; then dpkg --audit; else echo "  ninguno"; fi

echo; echo "== 5. ¿Hace falta reiniciar? =="
if [ -f /var/run/reboot-required ]; then
    cat /var/run/reboot-required
    [ -f /var/run/reboot-required.pkgs ] && sed 's/^/  /' /var/run/reboot-required.pkgs
else
    echo "  no"
fi

echo; echo "== 6. Kernels instalados =="
dpkg -l 'linux-image-[0-9]*' 2>/dev/null | awk '/^ii/{print "  "$2" "$3}'
echo "  en ejecución: $(uname -r)"

echo; echo "== 7. DKMS =="
dkms status 2>/dev/null | sed 's/^/  /'

echo; echo "== 8. Flatpak =="
if command -v flatpak >/dev/null 2>&1; then
    OUT="$(flatpak remote-ls --updates 2>/dev/null)"
    if [ -n "$OUT" ]; then echo "$OUT" | sed 's/^/  /'; else echo "  (sin actualizaciones)"; fi
else
    echo "  flatpak no instalado"
fi

echo; echo "== 9. Paquetes retenidos (hold) =="
H="$(apt-mark showhold 2>/dev/null)"; if [ -n "$H" ]; then echo "$H" | sed 's/^/  /'; else echo "  ninguno"; fi
