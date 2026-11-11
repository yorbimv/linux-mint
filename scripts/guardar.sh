#!/usr/bin/env bash
# Vuelca la configuración actual de este equipo al repo.
#
#   ./scripts/guardar.sh          captura todo
#   ./scripts/guardar.sh --dry    muestra qué haría, sin escribir
#
# No necesita root: solo lee archivos que tu usuario puede leer.
set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY=0
[ "${1:-}" = "--dry" ] && DRY=1

export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

ok()   { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
skip() { printf "  \033[2m· %s\033[0m\n" "$*"; }
warn() { printf "  \033[1;33m!\033[0m %s\n" "$*"; }

save() { # save <archivo> <destino dentro del repo>
  local src="$1" rel="$2" dst="$REPO/$2"
  [ -e "$src" ] || { skip "no existe: $src"; return; }
  if [ "$DRY" = 1 ]; then ok "(dry) $src -> $rel"; return; fi
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst" && ok "$rel"
}

echo "== Dotfiles de usuario =="
save "$HOME/.bashrc"                          "dotfiles/bash/.bashrc"
save "$HOME/.profile"                         "dotfiles/bash/.profile"
save "$HOME/.config/opencode/opencode.json"   "dotfiles/opencode/opencode.json"

echo
echo "== Sistema =="
save "/etc/default/keyboard"                  "dotfiles/sistema/keyboard"

# Extrae solo el bloque "mac" de /usr/share/X11/xkb/symbols/es
if grep -q 'xkb_symbols "mac"' /usr/share/X11/xkb/symbols/es 2>/dev/null; then
  if [ "$DRY" = 1 ]; then
    ok "(dry) variante es(mac) -> dotfiles/xkb/es-mac-variant.xkb"
  else
    awk '/^\/\/ Spanish \(Macintosh\)/{f=1} f' /usr/share/X11/xkb/symbols/es \
      > "$REPO/dotfiles/xkb/es-mac-variant.xkb" \
      && ok "dotfiles/xkb/es-mac-variant.xkb" \
      || warn "no se pudo extraer la variante mac"
  fi
else
  warn "la variante es(mac) no está instalada; se conserva la copia del repo"
fi

echo
echo "== Cinnamon =="
if command -v dconf >/dev/null 2>&1; then
  if [ "$DRY" = 1 ]; then
    ok "(dry) dconf /org/cinnamon/ -> dotfiles/cinnamon/dconf-cinnamon.ini"
  else
    dconf dump /org/cinnamon/ > "$REPO/dotfiles/cinnamon/dconf-cinnamon.ini" \
      && ok "dotfiles/cinnamon/dconf-cinnamon.ini" \
      || warn "no se pudo volcar dconf (¿sesión gráfica activa?)"
  fi
else
  skip "dconf no instalado"
fi

echo
echo "== Paquetes y repos =="
if [ "$DRY" = 0 ]; then
  apt-mark showmanual > "$REPO/paquetes/apt-manual.txt" 2>/dev/null \
    && ok "paquetes/apt-manual.txt ($(wc -l < "$REPO/paquetes/apt-manual.txt") paquetes)"

  flatpak list --app --columns=application,version > "$REPO/paquetes/flatpak.txt" 2>/dev/null \
    && ok "paquetes/flatpak.txt" || skip "flatpak sin apps"

  ls -1 /etc/apt/sources.list.d/ 2>/dev/null | grep -vE '\.(save|bak|distUpgrade)$' \
    > "$REPO/paquetes/repos-apt.txt" && ok "paquetes/repos-apt.txt"

  for f in /etc/apt/sources.list.d/*.list; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in
      official-package-repositories.list) continue ;;
    esac
    cp -a "$f" "$REPO/paquetes/" && ok "paquetes/$(basename "$f")"
  done
else
  ok "(dry) apt-mark showmanual -> paquetes/apt-manual.txt"
  ok "(dry) flatpak list -> paquetes/flatpak.txt"
  ok "(dry) /etc/apt/sources.list.d -> paquetes/repos-apt.txt"
fi

echo
echo "== Ajustes de RustDesk (solo ajustes, sin credenciales) =="
if [ -f "$HOME/.config/rustdesk/RustDesk2.toml" ]; then
  if [ "$DRY" = 1 ]; then
    ok "(dry) ajustes de vídeo de RustDesk"
  else
    grep -hE '^(codec-preference|use-texture-render|direct-server|enable-audio|enable-file-transfer|av1-test)' \
      "$HOME/.config/rustdesk/RustDesk2.toml" \
      "$HOME/.config/rustdesk/RustDesk_default.toml" \
      2>/dev/null | sort -u > "$REPO/dotfiles/rustdesk/ajustes.toml" \
      && ok "dotfiles/rustdesk/ajustes.toml"
  fi
else
  skip "RustDesk no configurado"
fi

echo
if [ "$DRY" = 0 ] && command -v git >/dev/null 2>&1 && [ -d "$REPO/.git" ]; then
  echo "== Cambios pendientes =="
  git -C "$REPO" status --short | sed 's/^/  /'
  echo
  echo "Revisa, y luego:"
  echo "  git add -A && git commit -m \"config: $(date +%Y-%m-%d)\" && git push"
fi
echo "Listo."
