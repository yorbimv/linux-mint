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

Guía y dotfiles para dejar este MacBook con Linux Mint **listo para trabajar desde cero**.

El tutorial empieza por lo básico: **necesitas un USB y descargar la imagen de Linux Mint**. Después se instala el sistema y este repo aplica toda la configuración del equipo: WiFi Broadcom BCM4331, teclado Mac español, trackpad, atajos estilo macOS, aplicaciones, entorno de desarrollo y RustDesk.

Los scripts son idempotentes: se pueden volver a ejecutar sin romper nada.

---

## 1. Necesitas un USB

| Dato          | Valor                                                              |
| ------------- | ------------------------------------------------------------------ |
| Tamaño        | **4 GB mínimo**, 8 GB o más recomendado                            |
| Estado        | **Se borra por completo** (no guardes nada importante en él)       |
| Conexión      | USB 2.0 o 3.0; en el MacBook, mejor el puerto izquierdo            |
| Para crear la USB | Este Linux Mint, otro Linux, macOS o Windows                   |

> ⚠️ **Antes de continuar:** respalda tus archivos personales. Al instalar Linux Mint se borra el disco completo del MacBook.

## 2. Descarga la imagen de Linux Mint

Descarga la **ISO oficial** de Linux Mint 22.3 “Zena” Cinnamon de 64 bits (~2.9 GB):

### ⬇️ [Descargar linuxmint-22.3-cinnamon-64bit.iso](https://mirrors.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso)

También puedes usar:

- [Página oficial de descargas](https://linuxmint.com/download.php)
- [Descarga por torrent](https://linuxmint.com/torrents/linuxmint-22.3-cinnamon-64bit.iso.torrent)
- [Lista oficial de hashes SHA256](https://mirrors.kernel.org/linuxmint/stable/22.3/sha256sum.txt)

### Por terminal

```bash
cd ~/Descargas

# Descargar la imagen
curl -fLO https://mirrors.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso

# Descargar la lista de hashes y verificar
curl -fLO https://mirrors.kernel.org/linuxmint/stable/22.3/sha256sum.txt
sha256sum -c --ignore-missing sha256sum.txt
```

Debe responder `linuxmint-22.3-cinnamon-64bit.iso: OK`. Si no coincide, vuelve a descargarla.

## 3. Prepara la USB

Con la ISO descargada, escribe la imagen en el USB. Lo más fácil en Linux Mint es **USB Image Writer** (`mintstick`): selecciona la ISO, selecciona el USB y pulsa **Escribir**.

> 🍎 **Si la creas desde macOS, usa [balenaEtcher](https://etcher.balena.io/).** En este equipo fue el único método que produjo una USB que el MacBook reconociera; otras herramientas escribían la USB pero no aparecía en el selector de arranque.

Por terminal:

```bash
# Identifica el USB (ejemplo: /dev/sdb). ¡No lo confundas con el disco del sistema!
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS

# Escribe la ISO en el DISCO completo, sin número de partición
sudo dd if=~/Descargas/linuxmint-22.3-cinnamon-64bit.iso \
        of=/dev/sdb bs=4M status=progress oflag=sync

sync && sudo eject /dev/sdb
```

> 📘 Guía detallada para **Linux, macOS y Windows**, verificación SHA256 y solución de problemas: **[00 · Preparar la USB](00-preparar-usb/)**.

## 4. Instala Linux Mint

1. Apaga el MacBook y conecta la USB.
2. Enciende manteniendo pulsada **Option (⌥)** hasta ver el selector de arranque.
3. Elige **EFI Boot** → **Start Linux Mint**.
4. **Conecta el cable Ethernet.** El WiFi BCM4331 no funciona en la sesión live ni recién instalado.
5. Abre **Install Linux Mint** y elige:
   - Idioma: **Español (México)**
   - Teclado: **Spanish** (la variante Mac se instala después con este repo)
   - **Erase disk and install Linux Mint** (borra macOS y todo el disco)
   - Marca **Install multimedia codecs**
6. Usuario: `yorbimv` (para que coincidan las rutas de este repo).
7. Termina, reinicia y retira la USB.

> Si el instalador no crea bien el arranque EFI, en [00 · Instalación](00-preparar-usb/#5-instalar-linux-mint) están las particiones manuales (512 MB FAT32 en `/boot/efi` + ext4 en `/`).

## 5. Actualiza todo (por Ethernet)

> ⚠️ **Todavía no hay WiFi.** El driver BCM4331 se instala en el paso siguiente y hay que descargarlo de internet. Conecta el **cable Ethernet** (funciona sin configurar nada) y **no lo desconectes** hasta terminar el paso 6.

```bash
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y git dkms linux-headers-generic-hwe-24.04
```

## 6. Instala el driver WiFi (se descarga desde la web)

El paquete `broadcom-sta-dkms` trae el driver propietario `wl` y se baja de los repositorios por Ethernet.

**Opción recomendada (con este repo):**

```bash
git clone https://github.com/yorbimv/linux-mint.git ~/Documentos/GitHub/linux-mint
cd ~/Documentos/GitHub/linux-mint

./install.sh 1     # actualizar índices y paquetes
./install.sh 5     # instalar broadcom-sta-dkms + blacklist + cargar wl

sudo reboot
```

**Opción manual:**

```bash
sudo apt-get install -y broadcom-sta-dkms

printf 'blacklist b43\nblacklist b43legacy\nblacklist ssb\nblacklist bcma\nblacklist brcm80211\nblacklist brcmsmac\nblacklist brcmfmac\n' \
  | sudo tee /etc/modprobe.d/blacklist-bcm4331.conf

sudo update-initramfs -u
sudo modprobe -r b43 b43legacy ssb bcma brcmsmac brcmfmac 2>/dev/null
sudo modprobe wl
sudo reboot
```

> Si `wl` no compila, el script del repo cae solo al driver libre `b43`. Detalle y recuperación sin red en [06 · WiFi BCM4331](06-hardware-macbook/wifi-bcm4331.md).

## 7. Comprueba el WiFi y desconecta el cable

Después del reinicio:

```bash
# Debe decir: Kernel driver in use: wl
lspci -k -s 02:00.0 | grep 'Kernel driver'

# Debe aparecer wlp2s0
ip -br link

# Conectarse a la red
nmcli device wifi list
nmcli device wifi connect "TU-RED" password "TU-CONTRASEÑA"

# La ruta por defecto debe salir por wlp2s0
ip route get 1.1.1.1
```

Cuando `ip route` salga por `wlp2s0`, ya puedes **desconectar el Ethernet**.

## 8. Aplica el resto de la configuración

Ya con WiFi:

```bash
cd ~/Documentos/GitHub/linux-mint
./install.sh
```

| Comando             | Qué hace                                            |
| ------------------- | --------------------------------------------------- |
| `./install.sh`      | Menú: elige un número, `n` = siguiente, `q` = salir  |
| `./install.sh 6`    | Ejecuta solo el paso 6                               |
| `./install.sh list` | Muestra los pasos y cuáles ya hiciste                |

- Cada paso **muestra lo que va a hacer** y pide confirmación `[s/N]`.
- Los dotfiles se enlazan uno por uno y se respalda lo que ya exista (`*.bak-<fecha>`).
- Los pasos que necesitan `root` lo piden con `sudo` en el momento.
- Los pasos **01** y **05** ya quedaron hechos en el paso 6 de esta guía; `install.sh` marcará el resto.

---

## Índice de secciones

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

## Qué incluye

| Área      | Herramientas / ajustes                                                        |
| --------- | ----------------------------------------------------------------------------- |
| USB       | ISO verificada, escritura con `dd`/Etcher, arranque `⌥` en el Mac             |
| Sistema   | `apt` al día, DKMS, drivers propietarios, Cinnamon afinado                     |
| Hardware  | WiFi BCM4331 con `wl`, teclado `es(mac)`, trackpad con clic derecho a 2 dedos, LED óptico del jack apagado |
| Atajos    | Toque de `⌘` abre el menú, `⌘Q` cerrar, `⌘M`/`⌘H` minimizar, `⌘⇧M` maximizar, `⌘Tab`, `⌘←/→` media pantalla; `Ctrl+←/→` cambia de escritorio y `Ctrl+Shift+←/→` pasa la ventana a otro escritorio |
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
- [ ] El LED rojo del jack de audífonos está apagado

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

**Antes de formatear:** respalda tus archivos, consigue el USB, descarga la ISO y ten el cable Ethernet a mano.

**Problemas comunes y soluciones en [troubleshooting/](troubleshooting/)**

**Última actualización:** Noviembre 2026
