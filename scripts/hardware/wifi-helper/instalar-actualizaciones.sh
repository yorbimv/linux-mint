#!/usr/bin/env bash
# Instala las actualizaciones pendientes y verifica el resultado.
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ $EUID -eq 0 ]] || { echo "ERROR: requiere root"; exit 1; }

echo "== 1. Instalando actualizaciones =="
apt-get -o DPkg::Lock::Timeout=900 dist-upgrade -y

echo; echo "== 2. Quedan pendientes? =="
apt list --upgradable 2>/dev/null | sed -n '2,$p' | sed 's/^/  /' || true
echo "  (si no aparece nada arriba, está todo al día)"

echo; echo "== 3. Auditoría dpkg =="
if dpkg --audit 2>&1 | grep -q .; then dpkg --audit; else echo "  ninguno"; fi

echo; echo "== 4. Reinicio requerido =="
if [ -f /var/run/reboot-required ]; then cat /var/run/reboot-required; else echo "  no"; fi

echo; echo "== 5. DKMS tras la actualización =="
dkms status 2>/dev/null | sed 's/^/  /'

echo; echo "== 6. Estado del WiFi =="
lspci -k -s 02:00.0 | grep "driver in use" | sed 's/^/  /'
nmcli -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null | sed 's/^/  /'
