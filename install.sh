#!/usr/bin/env bash
# Instalación guiada, un paso a la vez.
#   ./install.sh        → menú interactivo (marca ✓ los pasos ya hechos)
#   ./install.sh 3      → ejecuta solo el paso 3
#   ./install.sh list   → lista los pasos
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source scripts/lib.sh

STEPS=(scripts/steps/*.sh)
STATE="$HOME/.cache/linux-mint-bootstrap-done"; mkdir -p "$(dirname "$STATE")"; touch "$STATE"

title() { sed -n '2s/^# *//p' "$1"; }
num()   { basename "$1" | cut -d- -f1 | sed 's/^0//'; }
done_mark() { grep -qx "$(basename "$1")" "$STATE" && printf "✓" || printf " "; }

show() {
  printf "\n\033[1mPasos de instalación\033[0m  (✓ = ya ejecutado)\n\n"
  for s in "${STEPS[@]}"; do printf "  [%s] %2s  %s\n" "$(done_mark "$s")" "$(num "$s")" "$(title "$s")"; done
  echo
}

run() {
  local s; s=$(ls scripts/steps/ | grep -E "^0?$1-" | head -1)
  [ -n "$s" ] || { warn "No existe el paso $1"; return 1; }
  s="scripts/steps/$s"
  printf "\n\033[1;35m━━ Paso %s: %s\033[0m\n" "$(num "$s")" "$(title "$s")"
  bash "$s"; local rc=$?
  case $rc in
    0) grep -qx "$(basename "$s")" "$STATE" || basename "$s" >> "$STATE" ;;
    2) note "Paso omitido (no se marca como hecho)." ;;
    *) warn "El paso terminó con errores." ;;
  esac
}

case "${1:-}" in
  list) show; exit 0 ;;
  "")   ;;
  *)    run "$1"; exit 0 ;;
esac

while true; do
  show
  read -rp "Número de paso a ejecutar (n = siguiente pendiente, q = salir): " c
  case "$c" in
    q|Q|"") echo "Hasta luego. Los pasos manuales están en las secciones 01 a 07."; exit 0 ;;
    n|N) for s in "${STEPS[@]}"; do grep -qx "$(basename "$s")" "$STATE" || { run "$(num "$s")"; break; }; done ;;
    *[!0-9]*) warn "Opción no válida" ;;
    *) run "$c" ;;
  esac
done
