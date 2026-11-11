<p align="center">
  <b>🐧 Linux Mint · MacBook Pro A1278</b><br/>
  <sub>Configuración completa del equipo, reproducible desde cero</sub>
</p>

---

<p align="center">
  <a href="https://github.com/yorbimv/linux-mint">Inicio</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="01-sistema/">Sistema</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="02-aplicaciones/">Apps</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="03-dev-environment/">Dev</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="06-hardware-macbook/">Hardware</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="troubleshooting/">Soluciones</a>
</p>

---

# Linux Mint - Inicio

> Probado en **Linux Mint 22.3 (Zena)** · MacBook Pro 13" A1278 (2012) · Intel i5-3210M · 15 GB RAM
> Sesión **X11 / Cinnamon 6.6.9**

## Introducción

Guía y dotfiles para dejar este MacBook con Linux Mint **listo para trabajar desde cero**: actualizaciones, aplicaciones, entorno de desarrollo, atajos estilo macOS, el hardware peculiar de este equipo (WiFi Broadcom BCM4331, teclado Mac español, trackpad) y acceso remoto con RustDesk.

Todo lo que hay aquí se aplicó y verificó en este equipo. Los scripts son idempotentes: se pueden volver a ejecutar sin romper nada.

## Requisitos

- **Hardware:** MacBook Pro A1278 (o cualquier PC Intel/AMD que use Linux Mint).
- **Sistema:** Linux Mint 22.3 recién instalado, en **X11** (Wayland da problemas con RustDesk y con algunos atajos).
- **Cuenta de GitHub** para clonar el repo y subir cambios.
- **Internet** para descargar paquetes y drivers.
- **Ubicación del repo:** clonar en `~/Documentos/GitHub/linux-mint` para que las rutas coincidan con las de esta guía.

## Índice

| #   | Sección                                            | Descripción                                                |
| --- | -------------------------------------------------- | ---------------------------------------------------------- |
| 01  | [🖥️ Sistema](01-sistema/)                          | Actualizaciones, drivers, preferencias de Cinnamon         |
| 02  | [📦 Aplicaciones](02-aplicaciones/)                | Brave, Firefox, RustDesk, utilidades y lista de paquetes   |
| 03  | [💻 Dev Environment](03-dev-environment/)          | Bash, Git, GitHub CLI, VS Code, OpenCode                   |
| 04  | [⚡ Productividad](04-productividad/)               | Navegadores, correo, nube, atajos de teclado               |
| 05  | [🤖 IA Local](05-ia-local/)                        | OpenCode y MCP                                            |
| 06  | [🔧 Hardware MacBook](06-hardware-macbook/)        | WiFi BCM4331, teclado `es(mac)`, trackpad                  |
| 07  | [🖥️ RustDesk](07-rustdesk/)                         | Instalación, acceso remoto y problemas de "esperando imagen" |

## Instalación

### Automática

```bash
sudo apt install -y git
git clone https://github.com/yorbimv/linux-mint.git ~/Documentos/GitHub/linux-mint
cd ~/Documentos/GitHub/linux-mint && ./install.sh
```

| Comando             | Qué hace                                            |
| ------------------- | --------------------------------------------------- |
| `./install.sh`      | Menú: elige un número, `n` = siguiente, `q` = salir  |
| `./install.sh 4`    | Ejecuta solo el paso 4                               |
| `./install.sh list` | Muestra los pasos y cuáles ya hiciste                |

- Cada paso **muestra lo que va a hacer** y pide confirmación `[s/N]`.
- Los dotfiles se enlazan uno por uno y se respalda lo que ya exista (`*.bak-<fecha>`).
- Los pasos que necesitan `root` lo piden con `sudo` en el momento.

### Manual

Cada sección (01 a 07) explica los mismos pasos para hacerlos a mano, con los comandos y el porqué.

## Qué incluye

| Área      | Herramientas / ajustes                                                        |
| --------- | ----------------------------------------------------------------------------- |
| Sistema   | `apt` al día, DKMS, drivers propietarios, Cinnamon afinado                     |
| Hardware  | WiFi BCM4331 con `wl`, teclado `es(mac)`, trackpad con clic derecho a 2 dedos  |
| Atajos    | `⌘Q` cerrar, `⌘M`/`⌘H` minimizar, `⌘⇧M` maximizar, `⌘Tab`, `⌘←/→` media pantalla |
| Apps      | Brave (repo apt oficial), Firefox, Thunderbird, RustDesk 1.5.x, LibreOffice, Celluloid |
| Dev       | git, GitHub CLI, build-essential, VS Code, OpenCode                           |
| Remoto    | RustDesk como servicio, acceso no supervisado, ajustes de vídeo para GPU Intel |

## Verifica que quedó bien

- [ ] `./install.sh list` muestra los pasos hechos con ✓
- [ ] `ip route get 1.1.1.1` sale por `wlp2s0` (WiFi) y hay internet
- [ ] `setxkbmap -query` devuelve `layout: es` y `variant: mac`
- [ ] Clic derecho con **dos dedos** en el trackpad
- [ ] `⌘⇧M` maximiza la ventana activa
- [ ] `systemctl is-active rustdesk` dice `active`

## Mantener el repo al día

```bash
cd ~/Documentos/GitHub/linux-mint
./scripts/guardar.sh      # vuelca la configuración actual del equipo al repo
git add -A && git commit -m "config: ..." && git push
```

- Nueva app → añádela a [`paquetes/apt-extra.txt`](paquetes/apt-extra.txt) y a la sección 02.
- Los dotfiles son **symlinks**: editar `~/.bashrc` ya modifica el repo, solo haz commit.
- Cambiaste un ajuste de Cinnamon → `./scripts/guardar.sh` lo captura en `dotfiles/cinnamon/dconf-cinnamon.ini`.

---

**Problemas comunes y soluciones en [troubleshooting/](troubleshooting/)**

**Última actualización:** Noviembre 2026
