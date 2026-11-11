#!/usr/bin/env bash
#
# WiFi Broadcom BCM4331 [14e4:4331] - MacBook Pro A1278 / Linux Mint 22.x
#
# Instala el driver propietario "wl" (broadcom-sta-dkms).
# Si la compilación contra el kernel actual falla, cae al driver libre b43
# con su firmware, para no dejarte sin WiFi.
#
# Uso:  sudo bash instalar-wifi-bcm4331.sh
#
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: ejecuta con: sudo bash \"$0\""
    exit 1
fi

log() { echo; echo "==> $*"; }

# Espera hasta 20 min a que otro proceso (aptk/mintupdate) libere el gestor de paquetes
LOCK_OPTS=(-o DPkg::Lock::Timeout=1200)

log "1/7  Actualizando índices de paquetes"
apt-get "${LOCK_OPTS[@]}" update || echo "AVISO: 'apt-get update' devolvió error, se continúa con los índices actuales."

log "2/7  Instalando driver propietario wl (broadcom-sta-dkms)"
WL_OK=0
if apt-get "${LOCK_OPTS[@]}" install -y broadcom-sta-dkms; then
    KVER="$(uname -r)"
    DKMS_OUT="$(dkms status 2>/dev/null || true)"
    # Ojo: no usar 'dkms status | grep -q' junto a pipefail (grep cierra el tubo
    # antes de tiempo, dkms recibe SIGPIPE y el pipeline se marca como fallido).
    if grep -q "^broadcom-sta/.*${KVER}.*: installed" <<<"$DKMS_OUT" \
       && modinfo wl >/dev/null 2>&1; then
        WL_OK=1
        echo "OK: wl compilado para ${KVER}"
    else
        echo "AVISO: el paquete se instaló pero DKMS no reporta el módulo para ${KVER}."
        echo "---- dkms status ----"; echo "$DKMS_OUT"
    fi
else
    echo "AVISO: falló la instalación de broadcom-sta-dkms."
    apt-get "${LOCK_OPTS[@]}" -f install -y || true
fi

if [[ $WL_OK -eq 1 ]]; then
    log "3/7  Bloqueando los módulos que compiten por la tarjeta"
    cat > /etc/modprobe.d/blacklist-bcm4331.conf <<'EOF'
# MacBook Pro A1278 (BCM4331): usar el driver propietario wl
blacklist b43
blacklist b43legacy
blacklist ssb
blacklist bcma
blacklist brcm80211
blacklist brcmsmac
blacklist brcmfmac
EOF

    log "4/7  Regenerando initramfs (para que el blacklist aplique al arrancar)"
    update-initramfs -u || echo "AVISO: update-initramfs falló; el módulo wl puede cargarse igual."

    log "5/7  Descargando módulos en conflicto y cargando wl"
    modprobe -r b43legacy b43 ssb bcma brcmsmac brcmfmac brcm80211 2>/dev/null || true
    if ! modprobe wl; then
        echo "ERROR: no se pudo cargar wl. Últimas líneas de dmesg:"
        dmesg | tail -20
        exit 1
    fi
else
    log "3/7  Instalando driver libre b43 + firmware"
    if ! apt-get "${LOCK_OPTS[@]}" install -y firmware-b43-installer; then
        echo "ERROR: tampoco se pudo instalar el firmware de b43."
        echo "Revisa tu conexión y ejecuta: sudo apt-get install -y firmware-b43-installer"
        exit 1
    fi

    log "4/7  Evitando que wl tome la tarjeta"
    printf '# MacBook Pro A1278 (BCM4331): usar el driver libre b43\nblacklist wl\n' \
        > /etc/modprobe.d/blacklist-bcm4331.conf
    update-initramfs -u || true

    log "5/7  Recargando b43"
    modprobe -r b43 ssb bcma 2>/dev/null || true
    modprobe b43 || { echo "ERROR: no se pudo cargar b43"; exit 1; }
fi

log "6/7  Asegurando que el firmware esté disponible y desbloqueando la radio"
rfkill unblock all 2>/dev/null || true
if command -v nmcli >/dev/null; then
    nmcli radio wifi on 2>/dev/null || true
fi

log "7/7  Estado final"
sleep 2
ip -br link
echo
if command -v nmcli >/dev/null; then
    nmcli device status || true
fi
echo
lspci -k -s 02:00.0 2>/dev/null | sed 's/^/  /'
echo
echo "-------------------------------------------------------------"
echo " Si ves una interfaz inalámbrica (wlp2s0) en estado 'disconnected',"
echo " el driver ya está funcionando: reinicia para dejar todo limpio."
echo "     sudo reboot"
echo "-------------------------------------------------------------"
