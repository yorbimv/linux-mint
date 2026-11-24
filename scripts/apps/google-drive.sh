#!/usr/bin/env bash
# Instalar el cliente de Google Drive (rclone) en ~/.local/bin SIN sudo y montarlo en ~/Google Drive.
# Uso: bash scripts/apps/google-drive.sh
# Requiere: curl, unzip (ya presentes en Linux Mint).
# La autorización OAuth se hace una sola vez con: rclone authorize drive
set -euo pipefail

RCLONE_URL="https://downloads.rclone.org/rclone-current-linux-amd64.zip"
BIN_DIR="$HOME/.local/bin"
MNT_DIR="$HOME/Google Drive"
UNIT="$HOME/.config/systemd/user/rclone-gdrive.service"

mkdir -p "$BIN_DIR" "$MNT_DIR"

if [ -x "$BIN_DIR/rclone" ]; then
    echo "rclone ya está instalado: $($BIN_DIR/rclone version | head -1)"
else
    echo "Descargando rclone..."
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT
    curl -fL --retry 3 -o "$TMP/rclone.zip" "$RCLONE_URL"
    unzip -oq "$TMP/rclone.zip" -d "$TMP/extract"
    BIN=$(find "$TMP/extract" -type f -name rclone -perm -u+x | head -1)
    [ -n "$BIN" ] || { echo "ERROR: no se encontró el binario rclone"; exit 1; }
    cp "$BIN" "$BIN_DIR/rclone"
    chmod +x "$BIN_DIR/rclone"
    echo "Instalado: $($BIN_DIR/rclone version | head -1)"
fi

# ~/.profile ya añade ~/.local/bin al PATH; el shell actual puede no tenerlo.
echo "Añadiendo ~/.local/bin al PATH de sesiones nuevas (si falta)..."
if ! grep -q '\.local/bin' "$HOME/.profile" 2>/dev/null; then
    printf '\n# Clientes de nube instalados sin sudo\nif [ -d "$HOME/.local/bin" ] ; then\n    PATH="$HOME/.local/bin:$PATH"\nfi\n' >> "$HOME/.profile"
fi

# Servicio de usuario: monta el remote gdrive: en ~/Google Drive al iniciar sesión.
echo "Creando $UNIT ..."
mkdir -p "$(dirname "$UNIT")"
cat > "$UNIT" <<'EOF'
[Unit]
Description=Montar Google Drive (rclone) en ~/Google Drive
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=%h/.local/bin/rclone mount gdrive: "%h/Google Drive" \
  --vfs-cache-mode writes \
  --vfs-cache-max-age 24h \
  --dir-cache-time 72h \
  --poll-interval 1m \
  --umask 002 \
  --timeout 1h \
  --retries 3
ExecStop=-/bin/fusermount -uz "%h/Google Drive"
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable rclone-gdrive.service

echo
echo "=== Autorización (solo la primera vez) ==="
echo "  $BIN_DIR/rclone authorize drive"
echo "  Inicia sesión en el navegador y pega el token en ~/.config/rclone/rclone.conf:"
echo "  [gdrive]"
echo "  type = drive"
echo "  scope = drive"
echo "  token = {\"access_token\":...,\"refresh_token\":...,\"token_type\":\"Bearer\",\"expiry\":...}"
echo "  chmod 600 ~/.config/rclone/rclone.conf"
echo
echo "=== Arrancar el montaje ==="
echo "  systemctl --user start rclone-gdrive.service"
echo "  systemctl --user status rclone-gdrive.service"
