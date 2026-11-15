#!/usr/bin/env bash
# Instala Visual Studio Code estable desde el repositorio oficial de Microsoft.
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

KEYRING=/etc/apt/keyrings/packages.microsoft.gpg
LIST=/etc/apt/sources.list.d/vscode.list
KEYURL=https://packages.microsoft.com/keys/microsoft.asc
REPO="https://packages.microsoft.com/repos/code stable main"
# Huella de la clave "Microsoft (Release signing) <gpgsecurity@microsoft.com>"
FPR_ESPERADA=BC528686B50D79E339D3721CEB3E94ADBE1229CF

echo "== 1/5  Clave de firma de Microsoft =="
tmp="$(mktemp)"
if ! curl -fsSL --max-time 90 -o "$tmp" "$KEYURL"; then
    echo "ERROR: no se pudo descargar la clave"; rm -f "$tmp"; exit 1
fi
FPR="$(gpg --show-keys --with-colons --with-fingerprint "$tmp" 2>/dev/null | awk -F: '/^fpr:/{print $10; exit}')"
if [[ "$FPR" != "$FPR_ESPERADA" ]]; then
    echo "ERROR: huella inesperada: ${FPR:-no detectada}"
    echo "   esperada: $FPR_ESPERADA"
    rm -f "$tmp"; exit 1
fi
install -Dm644 "$tmp" "$KEYRING"
gpg --show-keys --with-fingerprint "$KEYRING" 2>/dev/null | sed -n '1,4p' | sed 's/^/   /'
rm -f "$tmp"

echo
echo "== 2/5  Repositorio apt =="
echo "deb [arch=amd64,arm64,armhf signed-by=$KEYRING] $REPO" > "$LIST"
sed 's/^/   /' "$LIST"

echo
echo "== 3/5  Actualizando indices =="
echo "   esperando a que no haya otro proceso usando apt..."
wait_lock /var/lib/apt/lists/lock 1200 || true
wait_lock /var/lib/dpkg/lock-frontend 1200 || true
apt-get -o DPkg::Lock::Timeout=900 -o Acquire::Retries=3 update 2>&1 | tail -6

echo
echo "== 4/5  Instalando code =="
wait_lock /var/lib/dpkg/lock-frontend 1200 || true
apt-get -o DPkg::Lock::Timeout=900 -o Acquire::Retries=3 install -y code

echo
echo "== 5/5  Verificacion =="
dpkg -l code 2>/dev/null | tail -1 | awk '{print "   paquete:", $2, $3}'
printf "   binario: %s\n" "$(command -v code || echo NO ENCONTRADO)"
printf "   version: %s\n" "$(code --version 2>/dev/null | head -1 || echo NO DISPONIBLE)"
printf "   lanzador: %s\n" "$(ls /usr/share/applications/com.microsoft.VSCode.desktop 2>/dev/null || echo NO ENCONTRADO)"
echo
echo "Listo."
