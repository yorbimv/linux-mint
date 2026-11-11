#!/usr/bin/env bash
# Resumen rapido del estado de RustDesk y de la ultima sesion registrada.
set -uo pipefail
LOG="$HOME/.local/share/logs/RustDesk/rustdesk_rCURRENT.log"

echo "== Servicio y procesos =="
systemctl is-active rustdesk.service 2>/dev/null | sed 's/^/  servicio: /'
pgrep -af "rustdesk" | grep -v pgrep | sed 's/^/  /'

echo
echo "== Ajustes de video =="
grep -H -E "^(codec-preference|use-texture-render)" \
  "$HOME/.config/rustdesk/RustDesk2.toml" \
  "$HOME/.config/rustdesk/RustDesk_default.toml" \
  "$HOME"/.config/rustdesk/peers/*.toml 2>/dev/null | sed 's/^/  /'

echo
echo "== Ultima sesion (resumen) =="
if [ -f "$LOG" ]; then
  grep -aE "Session [0-9]+ start|rendezvous server|Connection secured|relay requested|new video handler|decoder (success|failed)|recved audio format|handle_peer_info|Set fps|Exit io_loop|connection is not allowed|not allowed|incoming|Connect" "$LOG" \
    | grep -av "handle_peer_info" | tail -20 | cut -c1-200
  echo
  echo "  lineas con 'frame': $(grep -ac -iE 'frame' "$LOG")"
  echo "  ultima modificacion: $(stat -c %y "$LOG" 2>/dev/null)"
else
  echo "  (sin log)"
fi
