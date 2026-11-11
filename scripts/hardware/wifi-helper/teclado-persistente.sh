#!/usr/bin/env bash
# Re-persiste el teclado español con la variante mac en /etc/default/keyboard.
# Útil después de una actualización que haya reescrito el archivo.
# (La instalación completa de la variante la hace instalar-teclado-mac.sh.)
set -uo pipefail
[[ $EUID -eq 0 ]] || { echo "ERROR: requiere root"; exit 1; }

KB=/etc/default/keyboard
cp -a "$KB" "$KB.bak.$(date +%Y%m%d-%H%M%S)"

echo "== antes =="
grep -E '^XKB' "$KB"

cat > "$KB" <<'EOF'
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="es"
XKBVARIANT="mac"
XKBOPTIONS="terminate:ctrl_alt_bksp,ctrl:swap_lwin_lctl"

BACKSPACE="guess"
EOF

echo
echo "== después =="
grep -E '^XKB' "$KB"

echo
echo "== respaldo =="
ls -1 "$KB".bak.* | tail -1
