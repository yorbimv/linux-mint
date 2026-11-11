# Bash

El shell por defecto es Bash 5.2 con el `.bashrc` estándar de Linux Mint. No hay personalizaciones agresivas: solo los alias de siempre y `~/.local/bin` en el `PATH`.

## Archivos

| Archivo        | Contenido                                                        |
| -------------- | ---------------------------------------------------------------- |
| `~/.bashrc`    | Configuración interactiva: `PS1`, colores, alias, historial       |
| `~/.profile`   | Se ejecuta al iniciar sesión; añade `~/bin` y `~/.local/bin` al `PATH` |
| `~/.bash_aliases` | Opcional; `.bashrc` lo carga si existe (en este equipo no existe) |

Los dos primeros están versionados en [`dotfiles/bash/`](../dotfiles/bash/) y el paso `04-dotfiles` los enlaza con symlinks.

## Alias disponibles

```bash
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send ...'   # avisa cuando termina un comando largo
```

## Añadir alias propios

La forma limpia es crear `~/.bash_aliases` (no está en el repo para no mezclar config personal con la del equipo):

```bash
cat >> ~/.bash_aliases <<'EOF'
alias actualizar='sudo apt-get update && sudo apt-get upgrade'
alias repo='cd ~/Documentos/GitHub/linux-mint'
alias gs='git status --short'
alias ll='ls -alF --group-directories-first'
EOF
source ~/.bashrc
```

## Prompt

El `PS1` es el de Mint: usuario@host en verde, ruta en azul y `$`/`#` según el usuario.

```bash
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

## Historial

Mint configura un historial grande y lo guarda al cerrar cada sesión:

```bash
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend
```

Comandos útiles:

```bash
history | grep apt          # buscar en el historial
Ctrl+R                      # búsqueda inversa
!!                          # repetir el último comando
sudo !!                     # repetirlo con sudo
```

## Scripts de este repo

Siempre que un paso necesite `sudo` con diálogo gráfico se puede usar `SUDO_ASKPASS`:

```bash
export SUDO_ASKPASS="$PWD/.wifi-helper/askpass.sh"
sudo -A apt-get install -y paquete
```

En este repo el equivalente es cualquier script de `scripts/`; `install.sh` ya se encarga de pedir la contraseña cuando hace falta.
