#!/usr/bin/env bash
# Instalar y montar OneDrive con rclone en ~/.local/bin SIN sudo.
# Uso: bash scripts/apps/onedrive.sh
# Requiere: rclone (ver scripts/apps/google-drive.sh) ya instalado en ~/.local/bin.
set -euo pipefail

RCLONE="$HOME/.local/bin/rclone"
MNT_DIR="$HOME/OneDrive"
UNIT="$HOME/.config/systemd/user/rclone-onedrive.service"

if [ ! -x "$RCLONE" ]; then
    echo "ERROR: falta rclone. Ejecuta primero: bash scripts/apps/google-drive.sh"
    exit 1
fi

mkdir -p "$MNT_DIR"

echo "=== Autorización (solo la primera vez) ==="
echo "  $RCLONE authorize onedrive"
echo "  Inicia sesión en el navegador y pega el token en ~/.config/rclone/rclone.conf:"
echo "  [onedrive]"
echo "  type = onedrive"
echo "  token = {\"access_token\":...,\"refresh_token\":...,\"token_type\":\"Bearer\",\"expiry\":...}"
echo "  drive_type = personal"
echo "  drive_id = <ID de https://graph.microsoft.com/v1.0/me/drive>"
echo "  chmod 600 ~/.config/rclone/rclone.conf"
echo
echo "=== Servicio de usuario ==="
mkdir -p "$(dirname "$UNIT")"
cat > "$UNIT" <<'EOF'
[Unit]
Description=Montar OneDrive (rclone) en ~/OneDrive
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=%h/.local/bin/rclone mount onedrive: "%h/OneDrive" \
  --vfs-cache-mode writes \
  --vfs-cache-max-age 24h \
  --dir-cache-time 72h \
  --poll-interval 1m \
  --umask 002 \
  --timeout 1h \
  --retries 3
ExecStop=-/bin/fusermount -uz "%h/OneDrive"
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable rclone-onedrive.service
echo "Servicio instalado. Arranca con:"
echo "  systemctl --user start rclone-onedrive.service"
