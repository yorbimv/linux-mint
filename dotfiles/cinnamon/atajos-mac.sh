#!/usr/bin/env bash
# Atajos de ventana estilo macOS para Cinnamon.
# La tecla Cmd del MacBook es ahora Control (opcion ctrl:swap_lwin_lctl),
# por eso "Cmd+X" se escribe en Cinnamon como "<Control>x".
#
#   ./atajos-mac.sh            aplica los atajos estilo Mac
#   ./atajos-mac.sh --revertir vuelve a los valores originales de Cinnamon
set -uo pipefail

export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

WM=org.cinnamon.desktop.keybindings.wm
MODO="${1:-aplicar}"

# Cambia la tecla que abre el menu del applet menu@cinnamon.org.
# Se aplica en caliente por DBus y se persiste en la config del applet.
set_overlay_key() {
    local key="$1"
    if command -v gdbus >/dev/null 2>&1; then
        gdbus call --session --dest org.Cinnamon --object-path /org/Cinnamon \
            --method org.Cinnamon.Eval \
            "const boxes=[Main.panel._leftBox,Main.panel._centerBox,Main.panel._rightBox]; let a=null; for(const b of boxes){a=b.get_children().find(c=>c._uuid==='menu@cinnamon.org'); if(a)break;} if(a&&a._delegate){a._delegate.settings.setValue('overlay-key','$key'); a._delegate._updateKeybinding();}" \
            >/dev/null 2>&1 || true
    fi
    # Respaldo por si Cinnamon no estaba corriendo: editar el JSON del applet.
    python3 - "$HOME/.config/cinnamon/spices/menu@cinnamon.org" "$key" <<'PY' 2>/dev/null || true
import glob, json, os, sys
carpeta, key = sys.argv[1], sys.argv[2]
for f in glob.glob(os.path.join(carpeta, "*.json")):
    try:
        with open(f, encoding="utf-8") as fh:
            data = json.load(fh)
        if "overlay-key" in data:
            data["overlay-key"]["value"] = key
            with open(f, "w", encoding="utf-8") as fh:
                json.dump(data, fh, indent=4, ensure_ascii=False)
    except Exception:
        pass
PY
}

if [[ "$MODO" == "--revertir" ]]; then
    pkill -x xcape 2>/dev/null || true
    rm -f "$HOME/.config/autostart/xcape-cmd-menu.desktop"
    set_overlay_key 'Super_L::Super_R'
    gsettings set org.cinnamon.muffin locate-pointer-key "['Control_L']"
    gsettings set org.cinnamon.desktop.peripherals.mouse locate-pointer true
    gsettings set $WM close                     "['<Alt>F4']"
    gsettings set $WM minimize                  "@as []"
    gsettings set $WM switch-windows            "['<Alt>Tab']"
    gsettings set $WM switch-windows-backward   "['<Shift><Alt>Tab']"
    gsettings set $WM push-tile-left            "['<Super>Left']"
    gsettings set $WM push-tile-right           "['<Super>Right']"
    gsettings set $WM toggle-maximized          "['<Alt>F10']"
    echo "Atajos de ventana restaurados a los valores originales de Cinnamon."
else
    # Cmd+Q cerrar ventana
    gsettings set $WM close                     "['<Control>q','<Alt>F4']"
    # Cmd+M minimizar / Cmd+H ocultar (minimizar)
    gsettings set $WM minimize                  "['<Control>m','<Control>h']"
    # Cmd+Tab cambiar de ventana (Alt+Tab dejo de funcionar al ser Option = AltGr)
    gsettings set $WM switch-windows            "['<Control>Tab','<Super>Tab']"
    gsettings set $WM switch-windows-backward   "['<Shift><Control>Tab','<Shift><Super>Tab']"
    # Cmd+flechas llevar la ventana a media pantalla
    gsettings set $WM push-tile-left            "['<Control>Left','<Super>Left']"
    gsettings set $WM push-tile-right           "['<Control>Right','<Super>Right']"
    # Cmd+Shift+M maximizar / restaurar
    gsettings set $WM toggle-maximized          "['<Shift><Control>m','<Alt>F10']"
    echo "Atajos estilo macOS aplicados:"
    echo "  Cmd+Q        cerrar ventana"
    echo "  Cmd+M / Cmd+H minimizar"
    echo "  Cmd+Shift+M  maximizar / restaurar"
    echo "  Cmd+Tab      cambiar de ventana (Shift+Cmd+Tab al reves)"
    echo "  Cmd+Izq/Der  ventana a la mitad izquierda/derecha"

    # Ctrl fisico emite Super_L: se usa para "localizar el puntero" y NO
    # para abrir el menu.
    gsettings set org.cinnamon.desktop.peripherals.mouse locate-pointer true
    gsettings set org.cinnamon.muffin locate-pointer-key "['Super_L']"

    # La tecla Cmd emite Control_L. Con xcape, un TOQUE de Cmd envia la tecla
    # Menu (que abre/cierra el menu) y, si se mantiene pulsada, sigue siendo
    # Ctrl para Cmd+C, Cmd+V, Cmd+Q, etc.
    set_overlay_key 'Menu'
    if command -v xcape >/dev/null 2>&1; then
        mkdir -p "$HOME/.config/autostart"
        cat > "$HOME/.config/autostart/xcape-cmd-menu.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Cmd abre el menu
Comment=Un toque de Cmd abre el menu; mantenerla la usa como Ctrl
Exec=xcape -e Control_L=Menu
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
DESKTOP
        pkill -x xcape 2>/dev/null || true
        setsid -f xcape -e 'Control_L=Menu' >/dev/null 2>&1
        echo "  Toque de Cmd  abre/cierra el menu (mantener = Ctrl)"
        echo "  Ctrl (fisico) localiza el puntero"
    else
        echo "  (xcape no instalado: sudo apt-get install -y xcape)"
    fi
fi

echo
echo "Valores actuales:"
for k in close minimize toggle-maximized switch-windows switch-windows-backward push-tile-left push-tile-right; do
    printf "  %-24s %s\n" "$k" "$(gsettings get $WM $k)"
done
