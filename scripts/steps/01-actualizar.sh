#!/usr/bin/env bash
# Actualizar el sistema
source "$(dirname "$0")/../lib.sh"
say "Actualizar Linux Mint"
note "Se actualizan índices y paquetes. Puede tardar y pedir contraseña."
ask "¿Continuar?" || { note "Omitido."; exit 2; }

wait_lock /var/lib/apt/lists/lock 1200 || true
sudo apt-get -o DPkg::Lock::Timeout=900 -o Acquire::Retries=3 update
sudo apt-get -o DPkg::Lock::Timeout=900 -y upgrade
sudo apt-get -y autoremove --purge
sudo apt-get -y autoclean

if [ -f /var/run/reboot-required ]; then
  warn "Hay un reinicio pendiente: reinicia antes de seguir con los drivers."
fi
ok "Sistema actualizado."
