#!/usr/bin/env bash
# Cambia el WiFi BCM4331 del driver libre b43 al propietario wl.
set -uo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: ejecuta como root"
    exit 1
fi

log() { echo; echo "==> $*"; }

restore_b43() {
    echo "Restaurando el driver libre b43..."
    printf '# MacBook Pro A1278 (BCM4331): respaldo con driver libre b43\nblacklist wl\n' \
        > /etc/modprobe.d/blacklist-bcm4331.conf
    update-initramfs -u >/dev/null 2>&1 || true
    modprobe -r wl 2>/dev/null || true
    modprobe b43 || true
}

log "1/6  Comprobando que el módulo wl exista"
if ! modinfo wl >/dev/null 2>&1; then
    echo "ERROR: wl no está disponible. Ejecuta: sudo apt-get install --reinstall broadcom-sta-dkms"
    exit 1
fi

log "2/6  Quitando el bloqueo de wl y reforzando el de b43"
cat > /etc/modprobe.d/blacklist-bcm4331.conf <<'EOF'
# MacBook Pro A1278 (BCM4331): driver propietario wl
blacklist b43
blacklist b43legacy
blacklist ssb
blacklist bcma
blacklist brcm80211
blacklist brcmsmac
blacklist brcmfmac
EOF

log "3/6  Regenerando initramfs"
update-initramfs -u || echo "AVISO: update-initramfs falló, se continúa."

log "4/6  Liberando la tarjeta (descargando b43)"
for i in wlp2s0b1 wlp2s0 b1 wlan0; do ip link set "$i" down 2>/dev/null || true; done
command -v nmcli >/dev/null && nmcli device set wlp2s0b1 managed no >/dev/null 2>&1 || true
modprobe -r b43legacy b43 ssb bcma brcmsmac brcmfmac brcm80211 2>/dev/null || true

log "5/6  Cargando wl"
if ! modprobe wl; then
    echo "ERROR: no se pudo cargar wl. Últimas líneas de dmesg:"
    dmesg | tail -25
    restore_b43
    exit 1
fi

log "6/6  Estado final"
sleep 2
rfkill unblock all 2>/dev/null || true
command -v nmcli >/dev/null && { nmcli radio wifi on; nmcli device status; } || true
echo
ip -br link
echo
lspci -k -s 02:00.0 | sed 's/^/  /'
echo
if lspci -k -s 02:00.0 | grep -q "Kernel driver in use: wl"; then
    echo "OK: wl está controlando la tarjeta."
else
    echo "AVISO: wl no aparece como driver en uso. Revisa: dmesg | tail -30"
fi
