#!/usr/bin/env bash
# RustDesk: instalación y ajustes de vídeo
source "$(dirname "$0")/../lib.sh"
say "RustDesk"
echo "• Cliente y servicio (última versión desde GitHub)"
ask "  ¿Instalar/actualizar RustDesk?" && sudo bash "$REPO/scripts/apps/rustdesk.sh"

echo
echo "• Ajustes de vídeo para la GPU Intel de este equipo"
note "codec VP8 (evita HEVC por software) y render por CPU (evita pantalla negra)."
ask "  ¿Aplicar los ajustes de vídeo?" && bash "$REPO/dotfiles/rustdesk/video.sh"

echo
if systemctl is-enabled rustdesk.service >/dev/null 2>&1; then
  ok "Servicio rustdesk: $(systemctl is-active rustdesk.service)"
fi
note "Diagnóstico: ./dotfiles/rustdesk/estado.sh"
