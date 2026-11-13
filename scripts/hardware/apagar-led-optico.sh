#!/usr/bin/env bash
# Apaga el LED rojo (emisor óptico S/PDIF) del jack de audífonos del
# MacBook Pro A1278. Códec: Cirrus Logic CS4206 (tarjeta 0, HDA Intel PCH).
#
# El LED pertenece al transmisor óptico del jack combinado de 3.5 mm.
# No es una falla ni suciedad: el códec mantenía encendidos el convertidor
# digital (nodo 0x08) y el pin SPDIF del conector (nodo 0x10).
# Apagarlos no afecta el audio analógico (bocinas ni audífonos).
#
# Uso:
#   sudo bash scripts/hardware/apagar-led-optico.sh             # aplicar ahora
#   sudo bash scripts/hardware/apagar-led-optico.sh --instalar  # + servicio
set -uo pipefail

HW=/dev/snd/hwC0D0
CARD=0
DEST=/usr/local/lib/linux-mint

aplicar() {
    # Esperar a que el códec exista (arranque o vuelta de suspensión)
    for _ in $(seq 1 20); do
        [ -e "$HW" ] && break
        sleep 0.5
    done
    [ -e "$HW" ] || return 0

    # 1) Interruptores de la salida digital IEC958
    amixer -c "$CARD" sset 'IEC958' off >/dev/null 2>&1 || true
    amixer -c "$CARD" sset 'IEC958 Default PCM' off >/dev/null 2>&1 || true
    for i in 1 2 16; do
        amixer -c "$CARD" sset "IEC958",$i off >/dev/null 2>&1 || true
    done

    # 2) Convertidor digital (0x08) a D3 y pin SPDIF (0x10) deshabilitado
    if command -v hda-verb >/dev/null 2>&1; then
        hda-verb "$HW" 0x08 SET_CHANNEL_STREAMID 0x00 >/dev/null 2>&1 || true
        hda-verb "$HW" 0x08 SET_POWER_STATE 0x03 >/dev/null 2>&1 || true
        hda-verb "$HW" 0x10 SET_PIN_WIDGET_CONTROL 0x00 >/dev/null 2>&1 || true
    fi
}

instalar() {
    command -v hda-verb >/dev/null 2>&1 || apt-get install -y alsa-tools >/dev/null

    install -d "$DEST"
    install -m 0755 "$0" "$DEST/apagar-led-optico.sh"

    cat > /etc/systemd/system/macbook-led-optico.service <<'UNIT'
[Unit]
Description=Apagar el LED rojo (S/PDIF) del jack de audífonos del MacBook
After=sound.target
Wants=sound.target

[Service]
Type=oneshot
ExecStart=/usr/local/lib/linux-mint/apagar-led-optico.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT

    cat > /usr/lib/systemd/system-sleep/macbook-led-optico <<'HOOK'
#!/bin/sh
# Reaplica el apagado del LED óptico al volver de suspensión.
case "$1" in
    post) /usr/local/lib/linux-mint/apagar-led-optico.sh ;;
esac
HOOK
    chmod 0755 /usr/lib/systemd/system-sleep/macbook-led-optico

    # PipeWire/WirePlumber vuelve a encender el SPDIF al iniciar sesión.
    # Se reaplica automáticamente al entrar al escritorio y se permite que el
    # usuario ejecute SOLO este script sin contraseña.
    local usuario="${SUDO_USER:-}"
    if [ -n "$usuario" ] && [ "$usuario" != root ]; then
        printf '%s ALL=(root) NOPASSWD: %s/apagar-led-optico.sh\n' \
            "$usuario" "$DEST" > /etc/sudoers.d/linux-mint-led-optico
        chmod 0440 /etc/sudoers.d/linux-mint-led-optico
        visudo -cf /etc/sudoers.d/linux-mint-led-optico >/dev/null 2>&1 \
            || rm -f /etc/sudoers.d/linux-mint-led-optico

        cat > /etc/xdg/autostart/macbook-led-optico.desktop <<DESKTOP
[Desktop Entry]
Type=Application
Name=Apagar LED óptico del jack
Comment=Desactiva el transmisor S/PDIF del MacBook Pro A1278
Exec=sudo -n $DEST/apagar-led-optico.sh
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
DESKTOP
        chmod 0644 /etc/xdg/autostart/macbook-led-optico.desktop
    fi

    systemctl daemon-reload
    systemctl enable --now macbook-led-optico.service
    aplicar
    echo "Instalado: el LED se apaga al arrancar, al iniciar sesión y al volver de suspensión."
}

[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo." >&2; exit 1; }

case "${1:-}" in
    --instalar) instalar ;;
    *) aplicar ;;
esac
