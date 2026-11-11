#!/usr/bin/env bash
# Ajustes de compatibilidad de RustDesk para el MacBook Pro A1278 (GPU Intel HD 4000).
#
#   ./rustdesk-video.sh            aplica los ajustes
#   ./rustdesk-video.sh --revertir vuelve a los valores por defecto
#
# Que hace:
#   1. codec-preference = vp8   -> evita H.265. El equipo remoto (Mac) tiene que
#      codificar en HEVC y este MacBook lo decodifica por software con 1 hilo,
#      lo que puede dejar la sesion en "esperando imagen". VP8 se decodifica
#      mucho mas rapido y el Mac tambien lo soporta.
#   2. use-texture-render = N   -> dibuja el video por CPU en vez de por textura
#      GPU. En GPUs Intel antiguas la textura falla y la ventana queda en negro.
set -uo pipefail

CFG="$HOME/.config/rustdesk"
PEERS="$CFG/peers"
MODE="${1:-aplicar}"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$PEERS"
for f in "$CFG"/RustDesk2.toml "$CFG"/RustDesk_default.toml "$CFG"/peers/*.toml; do
    [ -f "$f" ] || continue
    cp -a "$f" "$f.bak.$STAMP"
done

# --- helper: fija clave = 'valor' dentro de la seccion [options] ---
set_opt() {
    local file="$1" key="$2" val="$3"
    touch "$file"
    python3 - "$file" "$key" "$val" <<'PY'
import sys, re
path, key, val = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    txt = open(path, encoding="utf-8").read()
except FileNotFoundError:
    txt = ""
if not re.search(r'^\[options\]$', txt, re.M):
    if txt and not txt.endswith("\n"):
        txt += "\n"
    txt += "\n[options]\n"
lines = txt.splitlines()
out, in_opts, done = [], False, False
for ln in lines:
    if ln.strip().startswith("[") and ln.strip().endswith("]"):
        if in_opts and not done:
            out.append(f"{key} = '{val}'"); done = True
        in_opts = ln.strip() == "[options]"
        out.append(ln); continue
    if in_opts and re.match(rf'^\s*{re.escape(key)}\s*=', ln):
        out.append(f"{key} = '{val}'"); done = True; continue
    out.append(ln)
if in_opts and not done:
    out.append(f"{key} = '{val}'"); done = True
if not done:
    out.append(f"{key} = '{val}'")
open(path, "w", encoding="utf-8").write("\n".join(out).rstrip() + "\n")
PY
}

if [[ "$MODE" == "--revertir" ]]; then
    for f in "$CFG"/RustDesk2.toml "$CFG"/RustDesk_default.toml "$CFG"/peers/*.toml; do
        [ -f "$f" ] || continue
        sed -i -E "/^codec-preference *=/d; /^use-texture-render *=/d" "$f"
    done
    echo "Ajustes revertidos (codec = auto, render por textura = automatico)."
else
    for f in "$PEERS"/*.toml; do
        [ -f "$f" ] || continue
        set_opt "$f" "codec-preference" "vp8"
    done
    set_opt "$CFG/RustDesk_default.toml" "codec-preference" "vp8"
    set_opt "$CFG/RustDesk2.toml" "use-texture-render" "N"
    echo "Aplicado: codec-preference = vp8, use-texture-render = N"
fi

echo
echo "Valores actuales:"
grep -H -E "^(codec-preference|use-texture-render)" "$CFG"/RustDesk2.toml "$CFG"/RustDesk_default.toml "$CFG"/peers/*.toml 2>/dev/null
echo
echo "Copias de seguridad con sufijo .bak.$STAMP"
