#!/usr/bin/env bash
# Instalar el visor de cámara guvcview y v4l-utils en ~/.local SIN sudo.
# Uso: bash scripts/apps/guvcview.sh
# Motivo: en este equipo el diálogo de zenity para la contraseña de sudo no responde.
# Los .deb se descargan con apt-get download y se extraen con dpkg-deb -x.
set -euo pipefail

BIN="$HOME/.local/bin"
LIB="$HOME/.local/lib"
APP="$HOME/.local/share/applications"
ICO="$HOME/.local/share/icons"

mkdir -p "$BIN" "$LIB" "$APP" "$ICO"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

PKGS="guvcview libguvcview-2.1-2t64 libgsl27 libgslcblas0 v4l-utils libv4l-0t64 libv4l2rds0t64"

echo "=== Descargando paquetes (sin sudo) ==="
( cd "$TMP" && apt-get download $PKGS )

echo "=== Extrayendo ==="
for deb in "$TMP"/*.deb; do
    dpkg-deb -x "$deb" "$TMP/root"
done

SYSLIB="$TMP/root/usr/lib/x86_64-linux-gnu"

echo "=== Copiando binarios ==="
# Copiar a un temporal y renombrar: funciona aunque haya una instancia abierta
# (cp directo sobre un ejecutable en uso da 'El archivo de texto está ocupado').
for bin in guvcview v4l2-ctl; do
    dest="$BIN/${bin/guvcview/guvcview-bin}"
    cp "$TMP/root/usr/bin/$bin" "$BIN/.$bin.new"
    chmod +x "$BIN/.$bin.new"
    mv -f "$BIN/.$bin.new" "$dest"
done

echo "=== Copiando librerías ==="
for patron in 'libgview*.so*' 'libgsl*.so*' 'libv4l*.so*'; do
    find "$SYSLIB" -maxdepth 1 -name "$patron" -exec cp -P {} "$LIB/" \;
done

echo "=== Copiando icono ==="
cp "$TMP/root/usr/share/pixmaps/guvcview/guvcview.png" "$ICO/guvcview.png"

echo "=== Wrapper con LD_LIBRARY_PATH ==="
cat > "$BIN/guvcview" <<'EOF'
#!/bin/sh
# guvcview instalado en ~/.local sin sudo; librerías en ~/.local/lib
export LD_LIBRARY_PATH="$HOME/.local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$HOME/.local/bin/guvcview-bin" "$@"
EOF
chmod +x "$BIN/guvcview"

echo "=== Añadiendo ~/.local/bin al PATH de sesiones nuevas (si falta) ==="
if ! grep -q '\.local/bin' "$HOME/.profile" 2>/dev/null; then
    printf '\n# Apps instaladas sin sudo\nif [ -d "$HOME/.local/bin" ] ; then\n    PATH="$HOME/.local/bin:$PATH"\nfi\n' >> "$HOME/.profile"
fi

echo "=== Lanzador del menú ==="
cat > "$APP/guvcview.desktop" <<EOF
[Desktop Entry]
Name=guvcview (Cámara)
GenericName=Visor de cámara
Comment=Ver y capturar vídeo de la cámara FaceTime HD
TryExec=$BIN/guvcview
Exec=$BIN/guvcview -d /dev/video0 -a none
Icon=$ICO/guvcview.png
Terminal=false
Type=Application
Categories=Video;AudioVideo;
StartupNotify=true
EOF
chmod +x "$APP/guvcview.desktop"
update-desktop-database "$APP" 2>/dev/null || true

echo "=== Verificación ==="
"$BIN/guvcview" --version
if LD_LIBRARY_PATH="$LIB" ldd "$BIN/guvcview-bin" | grep -q 'not found'; then
    echo "ERROR: faltan librerías:"
    LD_LIBRARY_PATH="$LIB" ldd "$BIN/guvcview-bin" | grep 'not found'
    exit 1
fi
echo "Librerías: OK"
if [ -e /dev/video0 ]; then
    LD_LIBRARY_PATH="$LIB" "$BIN/v4l2-ctl" -d /dev/video0 --info 2>/dev/null | grep -E 'Driver name|Card type' || true
else
    echo "Aviso: no hay /dev/video0 (¿cámara desconectada?)"
fi

echo
echo "Listo. Abre la app desde el menú (guvcview (Cámara)) o con:"
echo "  $BIN/guvcview -d /dev/video0 -a none"
echo
echo "Si no aparece en el menú, recarga Cinnamon con Ctrl+Alt+Esc."
echo "No lances dos instancias a la vez: el segundo dará 'Dispositivo o recurso ocupado'."
