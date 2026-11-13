#!/usr/bin/env bash
# Apagar el LED rojo (salida óptica S/PDIF) del jack de audífonos
source "$(dirname "$0")/../lib.sh"
say "LED rojo del jack de audífonos (transmisor óptico S/PDIF)"
note "El códec Cirrus Logic CS4206 enciende el transmisor óptico del jack"
note "combinado y deja el LED rojo fijo aunque no uses cable óptico."
note "Este paso lo apaga y lo mantiene apagado al arrancar, al iniciar"
note "sesión y al volver de suspensión. No afecta el audio normal."
ask "¿Instalar el apagado permanente ahora?" || { note "Omitido."; exit 2; }
sudo bash "$REPO/scripts/hardware/apagar-led-optico.sh" --instalar
ok "LED apagado y persistente."
