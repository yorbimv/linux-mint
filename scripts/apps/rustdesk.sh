#!/usr/bin/env bash
# Instala RustDesk desde el .deb oficial de GitHub (ultima version estable).
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "ERROR: requiere root"; exit 1; }
export DEBIAN_FRONTEND=noninteractive

wait_lock() {
    local f="$1" max="${2:-900}" t=0
    while fuser "$f" >/dev/null 2>&1; do
        sleep 5; t=$((t+5))
        if (( t >= max )); then echo "   AVISO: bloqueo persistente en $f"; return 1; fi
    done
    return 0
}

DEST=/tmp/opencode
mkdir -p "$DEST"

echo "== 1/5  Consultando la ultima version =="
JSON="$DEST/rustdesk-release.json"
curl -fsSL --max-time 60 -o "$JSON" https://api.github.com/repos/rustdesk/rustdesk/releases/latest
read -r VER URL NAME <<<"$(python3 - "$JSON" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
ver = d.get('tag_name', '')
for a in d.get('assets', []):
    n = a['name']
    if n.endswith('-x86_64.deb') and 'sciter' not in n and 'unattended' not in n:
        print(ver, a['browser_download_url'], n)
        break
PY
)"
[ -n "${URL:-}" ] || { echo "ERROR: no se encontro el .deb x86_64"; exit 1; }
echo "   version: $VER"
echo "   archivo: $NAME"

echo
echo "== 2/5  Descargando =="
DEB="$DEST/$NAME"
curl -fL --max-time 600 --retry 3 -o "$DEB" "$URL"
ls -l "$DEB" | awk '{printf "   %s  (%.1f MB)\n", $9, $5/1e6}'

echo
echo "== 3/5  Verificando el paquete =="
dpkg-deb -f "$DEB" Package Version Architecture 2>/dev/null | sed 's/^/   /'
dpkg-deb -I "$DEB" >/dev/null 2>&1 || { echo "ERROR: el .deb esta corrupto"; exit 1; }

echo
echo "== 4/5  Instalando (con dependencias) =="
wait_lock /var/lib/dpkg/lock-frontend 1200 || true
apt-get -o DPkg::Lock::Timeout=900 -o Acquire::Retries=3 install -y "$DEB"

echo
echo "== 5/5  Verificacion =="
dpkg -l rustdesk 2>/dev/null | tail -1 | awk '{print "   paquete:", $2, $3}'
printf "   binario: %s\n" "$(command -v rustdesk || echo NO ENCONTRADO)"
printf "   lanzador: %s\n" "$(ls /usr/share/applications/rustdesk.desktop 2>/dev/null || echo NO ENCONTRADO)"
echo "   servicio:"
systemctl is-enabled rustdesk.service 2>/dev/null | sed 's/^/     enabled: /' || true
systemctl is-active  rustdesk.service 2>/dev/null | sed 's/^/     active:  /' || true
echo
echo "Listo."
