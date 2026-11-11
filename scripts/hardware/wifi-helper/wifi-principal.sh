#!/usr/bin/env bash
# Hace que el WiFi (TELMEX) sea la conexión principal y el cable quede de respaldo.
set -uo pipefail
[[ $EUID -eq 0 ]] || { echo "ERROR: requiere root"; exit 1; }

WIFI="TELMEX"
WIRED="Wired connection 1"

log() { echo; echo "==> $*"; }

log "1/4  Prioridad y métrica del WiFi"
nmcli connection modify "$WIFI" \
    connection.autoconnect-priority 100 \
    ipv4.route-metric 50 \
    ipv6.route-metric 50
echo "   $WIFI -> prioridad 100, metrica 50 (gana la ruta por defecto)"

log "2/4  Métrica del cable (queda más alta = respaldo)"
nmcli connection modify "$WIRED" \
    connection.autoconnect-priority 0 \
    ipv4.route-metric 200 \
    ipv6.route-metric 200
echo "   $WIRED -> metrica 200 (solo se usa si el WiFi cae)"

log "3/4  Reactivando el WiFi"
nmcli connection up "$WIFI" || echo "AVISO: no se pudo reactivar $WIFI"

log "4/4  Comprobación"
sleep 2
echo "Ruta hacia internet:"
ip route get 1.1.1.1 | sed 's/^/   /'
echo
nmcli -f DEVICE,TYPE,STATE,CONNECTION device status
echo
echo "IP del WiFi: $(ip -4 -br addr show wlp2s0 2>/dev/null | awk '{print $3}')"
echo
echo "-------------------------------------------------------------"
echo " Para volver a los valores por defecto (cable preferido):"
echo "   sudo nmcli connection modify \"$WIFI\" ipv4.route-metric 600 ipv6.route-metric 600"
echo "   sudo nmcli connection modify \"$WIRED\" ipv4.route-metric 100 ipv6.route-metric 100"
echo "-------------------------------------------------------------"
