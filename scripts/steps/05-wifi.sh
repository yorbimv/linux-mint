#!/usr/bin/env bash
# WiFi Broadcom BCM4331 con driver propietario wl
source "$(dirname "$0")/../lib.sh"
say "WiFi Broadcom BCM4331"
note "Instala broadcom-sta-dkms y bloquea b43/ssb/bcma. Requiere reiniciar al final."
if ! lspci -nn 2>/dev/null | grep -qiE '14e4:4331|BCM4331'; then
  warn "No se detecta una BCM4331 en este equipo."
  ask "¿Ejecutar el script igualmente?" || { note "Omitido."; exit 2; }
fi
ask "¿Instalar/actualizar el driver wl ahora?" || { note "Omitido."; exit 2; }
sudo bash "$REPO/scripts/hardware/wifi-bcm4331.sh"

echo
warn "Reinicia para que el driver wl quede activo:  sudo reboot"
