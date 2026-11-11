#!/usr/bin/env bash
# Instala la variante "mac" (teclado Apple Spanish ISO) en xkb-data,
# la registra en el menu grafico y la persiste en /etc/default/keyboard.
# Es idempotente: se puede volver a ejecutar tras una actualizacion de xkb-data.
set -uo pipefail
[[ $EUID -eq 0 ]] || { echo "ERROR: requiere root"; exit 1; }

SYM=/usr/share/X11/xkb/symbols/es
XML=/usr/share/X11/xkb/rules/evdev.xml
LST=/usr/share/X11/xkb/rules/evdev.lst
BASE_LST=/usr/share/X11/xkb/rules/base.lst
KB=/etc/default/keyboard
HERE="$(cd "$(dirname "$0")" && pwd)"
BLOCK="$HERE/es-mac-variant.xkb"

[[ -f "$BLOCK" ]] || { echo "ERROR: falta $BLOCK"; exit 1; }

TS=$(date +%Y%m%d-%H%M%S)
for f in "$SYM" "$XML" "$LST" "$BASE_LST" "$KB"; do
    cp -a "$f" "$f.bak.$TS"
done
echo "Respaldos creados con sufijo .bak.$TS"

echo
echo "== 1/5  Variante en symbols/es =="
if grep -q 'xkb_symbols "mac"' "$SYM"; then
    echo "   ya existe, no se modifica"
else
    echo "" >> "$SYM"
    cat "$BLOCK" >> "$SYM"
    echo "   variante 'mac' anadida"
fi

echo
echo "== 2/5  Entrada en evdev.xml (menu grafico) =="
python3 - "$XML" <<'PY'
import re, sys
p = sys.argv[1]
x = open(p, encoding='utf-8').read()
m = re.search(r'<layout>\s*<configItem>\s*<name>es</name>', x)
if not m:
    print("   ERROR: layout 'es' no encontrado"); sys.exit(1)
end = x.find('</layout>', m.end())
if '<name>mac</name>' in x[m.start():end]:
    print("   ya existe, no se modifica"); sys.exit(0)
vl = x.find('<variantList>', m.end()) + len('<variantList>')
entry = ('\n        <variant>\n'
         '          <configItem>\n'
         '            <name>mac</name>\n'
         '            <description>Spanish (Macintosh)</description>\n'
         '          </configItem>\n'
         '        </variant>')
x = x[:vl] + entry + x[vl:]
open(p, 'w', encoding='utf-8').write(x)
print("   'Spanish (Macintosh)' registrado")
PY

echo
echo "== 3/5  Validacion del XML =="
python3 - "$XML" <<'PY'
import sys, xml.etree.ElementTree as ET
try:
    ET.parse(sys.argv[1])
    print("   XML valido")
except Exception as e:
    print("   XML INVALIDO:", e); sys.exit(1)
PY

echo
echo "== 4/5  /etc/default/keyboard =="
cat > "$KB" <<'EOF'
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="es"
XKBVARIANT="mac"
XKBOPTIONS="terminate:ctrl_alt_bksp,ctrl:swap_lwin_lctl"

BACKSPACE="guess"
EOF
grep -E '^XKB' "$KB" | sed 's/^/   /'

echo
echo "== 5/5  evdev.lst / base.lst (localectl) =="
for f in "$LST" "$BASE_LST"; do
    if grep -q '^  mac[[:space:]]*es:' "$f"; then
        echo "   $(basename "$f"): ya existe, no se modifica"
    else
        sed -i '/^  nodeadkeys[[:space:]]*es:/i\  mac             es: Spanish (Macintosh)' "$f"
        echo "   $(basename "$f"): 'mac -> Spanish (Macintosh)' anadido"
    fi
done

echo
echo "Listo. Configuracion del sistema instalada."
