# Funciones compartidas por install.sh y scripts/steps/*.sh
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

say()  { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }
note() { printf "    \033[2m%s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m!  %s\033[0m\n" "$*"; }
ok()   { printf "\033[1;32m✓  %s\033[0m\n" "$*"; }

# ask "pregunta" → 0 si responde s/y (default: no)
ask() {
  local r; read -rp "$1 [s/N] " r
  [[ "$r" =~ ^[sSyY]$ ]]
}

need_root() { [ "$(id -u)" -eq 0 ] || { warn "Este paso necesita root: ejecútalo con sudo."; exit 1; }; }

# Espera a que se libere un bloqueo de apt (p. ej. mint-refresh-ca)
wait_lock() {
  local f="$1" max="${2:-900}" t=0
  while fuser "$f" >/dev/null 2>&1; do
    sleep 5; t=$((t+5))
    if [ "$t" -ge "$max" ]; then warn "Bloqueo persistente en $f"; return 1; fi
  done
}

apt_install() {
  wait_lock /var/lib/apt/lists/lock 1200 || true
  wait_lock /var/lib/dpkg/lock-frontend 1200 || true
  sudo apt-get -o DPkg::Lock::Timeout=900 -o Acquire::Retries=3 install -y "$@"
}

# link origen destino → symlink con respaldo
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then note "ya enlazado: $dst"; return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then mv "$dst" "$dst.bak-$STAMP"; note "respaldo: $dst.bak-$STAMP"; fi
  ln -s "$src" "$dst"; note "$dst -> $src"
}

# Copia (no enlaza) preservando permisos y con respaldo
copy_cfg() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  [ -e "$dst" ] && cp -a "$dst" "$dst.bak-$STAMP" && note "respaldo: $dst.bak-$STAMP"
  install -Dm"${3:-644}" "$src" "$dst" && note "$dst"
}

have() { command -v "$1" >/dev/null 2>&1; }
