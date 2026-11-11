#!/usr/bin/env bash
# Instala Brave Browser desde el repositorio oficial de Brave.
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "ERROR: requiere root"; exit 1; }
export DEBIAN_FRONTEND=noninteractive

# Espera a que se libere un bloqueo de apt (p. ej. mint-refresh-ca)
wait_lock() {
    local f="$1" max="${2:-900}" t=0
    while fuser "$f" >/dev/null 2>&1; do
        sleep 5; t=$((t+5))
        if (( t >= max )); then
            echo "   AVISO: bloqueo persistente en $f"; return 1
        fi
    done
    return 0
}

KEYRING=/usr/share/keyrings/brave-browser-archive-keyring.gpg
LIST=/etc/apt/sources.list.d/brave-browser-release.list
KEYURL=https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
REPO="https://brave-browser-apt-release.s3.brave.com/ stable main"

echo "== 1/5  Clave de firma de Brave =="
tmp="$(mktemp)"
if ! curl -fsSL --max-time 90 -o "$tmp" "$KEYURL"; then
    echo "ERROR: no se pudo descargar la clave"; rm -f "$tmp"; exit 1
fi
if ! gpg --show-keys --with-fingerprint "$tmp" >/dev/null 2>&1; then
    echo "ERROR: el archivo descargado no es una clave PGP valida"; rm -f "$tmp"; exit 1
fi
install -Dm644 "$tmp" "$KEYRING"
rm -f "$tmp"
gpg --show-keys --with-fingerprint "$KEYRING" 2>/dev/null | sed -n '1,3p' | sed 's/^/   /'

echo
echo "== 2/5  Repositorio apt =="
echo "deb [signed-by=$KEYRING arch=amd64] $REPO" > "$LIST"
sed 's/^/   /' "$LIST"

echo
echo "== 3/5  Actualizando indices =="
echo "   esperando a que no haya otro proceso usando apt..."
wait_lock /var/lib/apt/lists/lock 1200 || true
wait_lock /var/lib/dpkg/lock-frontend 1200 || true
apt-get -o DPkg::Lock::Timeout=900 -o Acquire::Retries=3 update 2>&1 | tail -6

echo
echo "== 4/5  Instalando brave-browser =="
wait_lock /var/lib/dpkg/lock-frontend 1200 || true
apt-get -o DPkg::Lock::Timeout=900 -o Acquire::Retries=3 install -y brave-browser

echo
echo "== 5/5  Verificacion =="
dpkg -l brave-browser 2>/dev/null | tail -1 | awk '{print "   paquete:", $2, $3}'
printf "   binario: %s\n" "$(command -v brave-browser || echo NO ENCONTRADO)"
printf "   lanzador: %s\n" "$(ls /usr/share/applications/brave-browser.desktop 2>/dev/null || echo NO ENCONTRADO)"
echo
echo "Listo."
