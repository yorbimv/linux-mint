<p align="center">
  <b>🐧 Linux Mint · MacBook Pro A1278</b><br/>
  <sub>De la USB al equipo listo para trabajar, paso a paso</sub>
</p>

---

<p align="center">
  <a href="https://github.com/yorbimv/linux-mint">Inicio</a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="00-preparar-usb/">USB</a>
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

Guía y dotfiles para dejar este MacBook con Linux Mint **listo para trabajar desde cero**, empezando por lo primero: **preparar la USB con la imagen de Linux Mint**.

Después de instalar el sistema, este repo reproduce toda la configuración del equipo: actualizaciones, WiFi Broadcom BCM4331, teclado Mac español, trackpad, atajos estilo macOS, aplicaciones, entorno de desarrollo y acceso remoto con RustDesk.

Todo lo que hay aquí se aplicó y verificó en este equipo. Los scripts son idempotentes: se pueden volver a ejecutar sin romper nada.

## Empieza aquí

| Orden | Paso                                              | Dónde                                   |
| ----- | ------------------------------------------------- | --------------------------------------- |
| 1     | Preparar la USB con Linux Mint 22.3               | [00 · Preparar USB](00-preparar-usb/)   |
| 2     | Arrancar el MacBook e instalar Linux Mint         | [00 · Instalación](00-preparar-usb/#5-instalar-linux-mint) |
| 3     | Clonar este repo y ejecutar `./install.sh`        | [Instalación](#instalación)             |
| 4     | Verificar que todo quedó bien                     | [Verificación](#verifica-que-quedó-bien) |

## Requisitos

| Requisito        | Detalle                                                                 |
| ---------------- | ----------------------------------------------------------------------- |
| **USB**          | 4 GB mínimo (8 GB recomendado). **Se borra por completo.**              |
| **Imagen ISO**   | Linux Mint **22.3 “Zena” Cinnamon 64-bit** (~2.9 GB)                    |
| **Cable Ethernet** | **Obligatorio en este MacBook**: el WiFi BCM4331 no funciona en live ni recién instalado |
| **Respaldo**     | Tus archivos deben estar en la nube o en un disco externo                |
| **Cargador**     | La batería está al ~29 %; no alcanza para una instalación                |
| **Cuenta GitHub**| Para clonar el repo y subir cambios                                      |
| **Hardware**     | MacBook Pro A1278 o cualquier PC Intel/AMD con Linux Mint                |

> 📘 La guía completa de la USB (descarga, verificación SHA256, `dd`/Etcher/Rufus, arranque con `⌥` y particiones) está en **[00 · Preparar la USB](00-preparar-usb/)**.

### Resumen de la USB

```bash
# Descargar y verificar
cd ~/Descargas
curl -fLO https://mirrors.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso
curl -fLO https://mirrors.kernel.org/linuxmint/stable/22.3/sha256sum.txt
sha256sum -c --ignore-missing sha256sum.txt

# Escribir en la USB (identifica el disco con lsblk; ejemplo /dev/sdb)
lsblk -o NAME,SIZE,MODEL,TRAN
sudo dd if=linuxmint-22.3-cinnamon-64bit.iso of=/dev/sdb bs=4M status=progress oflag=sync
sync && sudo eject /dev/sdb
```

Para arrancar el Mac: apágalo, conecta la USB, enciende manteniendo **Option (⌥)** y elige **EFI Boot**.

## Índice

| #   | Sección                                            | Descripción                                                |
| --- | -------------------------------------------------- | ---------------------------------------------------------- |
| 00  | [💾 Preparar USB](00-preparar-usb/)                | Descargar la ISO, crear la USB, arrancar e instalar Mint   |
| 01  | [🖥️ Sistema](01-sistema/)                          | Actualizaciones, drivers, preferencias de Cinnamon         |
| 02  | [📦 Aplicaciones](02-aplicaciones/)                | Brave, Firefox, RustDesk, utilidades y lista de paquetes   |
| 03  | [💻 Dev Environment](03-dev-environment/)          | Bash, Git, GitHub CLI, OpenCode                            |
| 04  | [⚡ Productividad](04-productividad/)               | Navegadores, correo, ofimática y atajos de teclado         |
| 05  | [🤖 IA Local](05-ia-local/)                        | OpenCode, MCP y modelos locales (opcional)                 |
| 06  | [🔧 Hardware MacBook](06-hardware-macbook/)        | WiFi BCM4331, teclado `es(mac)`, trackpad y batería        |
| 07  | [🖥️ RustDesk](07-rustdesk/)                         | Instalación, acceso remoto y problemas de "esperando imagen" |

## Instalación

### 1. Sistema recién instalado

Después del paso [00](00-preparar-usb/), el equipo debe tener:

- Linux Mint 22.3 instalado en modo **UEFI** (sin Secure Boot).
- **Cable Ethernet** conectado y funcionando.
- Usuario `yorbimv` y sesión **X11 / Cinnamon**.

### 2. Clonar y ejecutar

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/yorbimv/linux-mint.git ~/Documentos/GitHub/linux-mint
cd ~/Documentos/GitHub/linux-mint && ./install.sh
```

| Comando             | Qué hace                                            |
| ------------------- | --------------------------------------------------- |
| `./install.sh`      | Menú: elige un número, `n` = siguiente, `q` = salir  |
| `./install.sh 5`    | Ejecuta solo el paso 5                               |
| `./install.sh list` | Muestra los pasos y cuáles ya hiciste                |

- Cada paso **muestra lo que va a hacer** y pide confirmación `[s/N]`.
- Los dotfiles se enlazan uno por uno y se respalda lo que ya exista (`*.bak-<fecha>`).
- Los pasos que necesitan `root` lo piden con `sudo` en el momento.
- El **paso 05** instala el WiFi; al terminar, reinicia y desconecta el cable.

### 3. Manual

Cada sección (00 a 07) explica los mismos pasos para hacerlos a mano, con los comandos y el porqué.

## Qué incluye

| Área      | Herramientas / ajustes                                                        |
| --------- | ----------------------------------------------------------------------------- |
| USB       | ISO verificada, escritura con `dd`/Etcher, arranque `⌥` en el Mac             |
| Sistema   | `apt` al día, DKMS, drivers propietarios, Cinnamon afinado                     |
| Hardware  | WiFi BCM4331 con `wl`, teclado `es(mac)`, trackpad con clic derecho a 2 dedos  |
| Atajos    | `⌘Q` cerrar, `⌘M`/`⌘H` minimizar, `⌘⇧M` maximizar, `⌘Tab`, `⌘←/→` media pantalla |
| Apps      | Brave (repo apt oficial), Firefox, Thunderbird, RustDesk 1.5.x, LibreOffice, Celluloid |
| Dev       | git, GitHub CLI, build-essential, Python y OpenCode                           |
| Remoto    | RustDesk como servicio, acceso no supervisado, ajustes de vídeo para GPU Intel |

## Verifica que quedó bien

- [ ] `./install.sh list` muestra los pasos hechos con ✓
- [ ] `ip route get 1.1.1.1` sale por `wlp2s0` (WiFi) y hay internet
- [ ] `setxkbmap -query` devuelve `layout: es` y `variant: mac`
- [ ] Clic derecho con **dos dedos** en el trackpad
- [ ] `⌘⇧M` maximiza la ventana activa
- [ ] `systemctl is-active rustdesk` dice `active`
- [ ] `brave-browser --version` responde

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

**Antes de formatear:** copia tus archivos, verifica la ISO y ten el cable Ethernet a mano. La guía está en **[00 · Preparar la USB](00-preparar-usb/)**.

**Problemas comunes y soluciones en [troubleshooting/](troubleshooting/)**

**Última actualización:** Noviembre 2026
