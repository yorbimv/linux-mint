# Soluciones

Índice de fallos que ya se resolvieron en este equipo. Si algo vuelve a pasar después de formatear, empieza por aquí.

## USB y arranque

| Problema                                        | Solución rápida                                                                 | Detalle |
| ----------------------------------------------- | ------------------------------------------------------------------------------- | ------- |
| La USB no aparece al mantener `⌥`                | Reescribirla con **balenaEtcher** (en macOS fue el único método que funcionó); probar el otro puerto | [USB](../00-preparar-usb/#si-la-usb-no-aparece-en-el-selector) |
| La ISO no pasa la verificación SHA256            | Descarga corrupta: volver a bajarla                                              | [USB](../00-preparar-usb/#verificar-la-descarga-obligatorio) |
| `dd: /dev/sdX: Permission denied`                | Falta `sudo` o el dispositivo es una partición (`sdb1` en vez de `sdb`)          | [USB](../00-preparar-usb/#opción-a--desde-linux-mint-la-más-fácil) |
| El Mac arranca directo a macOS                   | Mantener `⌥` desde el encendido; resetear NVRAM con `⌘+⌥+P+R`                    | [USB](../00-preparar-usb/#4-arrancar-el-macbook-desde-la-usb) |
| El instalador no arranca (pantalla negra)        | Probar la HWE ISO de Linux Mint                                                  | [USB](../00-preparar-usb/#si-la-usb-no-aparece-en-el-selector) |
| Tras instalar no hay WiFi                        | Es normal: conectar Ethernet, ejecutar el paso 05 y reiniciar                    | [WiFi](../06-hardware-macbook/wifi-bcm4331.md) |
| El instalador no crea el arranque EFI            | Particionar a mano: 512 MB FAT32 en `/boot/efi` + ext4 en `/`                   | [USB](../00-preparar-usb/#si-el-instalador-no-crea-bien-el-arranque-efi) |
| No aparece el menú de GRUB                       | Elegir Linux Mint en el selector de arranque del Mac (`⌥`)                       | — |

## Red

| Problema                                        | Solución rápida                                                                 | Detalle |
| ----------------------------------------------- | ------------------------------------------------------------------------------- | ------- |
| No aparece el WiFi tras actualizar               | `sudo dkms autoinstall` y reiniciar                                              | [WiFi](../06-hardware-macbook/wifi-bcm4331.md#actualizaciones-de-kernel) |
| El WiFi conecta pero no navega                   | `nmcli device status`, `ping -c2 1.1.1.1`, revisar DNS (`resolvectl status`)      | [WiFi](../06-hardware-macbook/wifi-bcm4331.md) |
| Solo redes de 2.4 GHz                            | Revisar canal/banda del router; el BCM4331 sí soporta 5 GHz                       | [WiFi](../06-hardware-macbook/wifi-bcm4331.md#5-ghz) |
| El cable no funciona                             | `lspci -k` debe mostrar `tg3`; `sudo modprobe tg3`                               | — |
| `apt` se queda en "Esperando..."                 | `mint-refresh-ca` tiene el lock: `sudo systemctl stop mint-refresh-ca`            | [Sistema](../01-sistema/README.md#actualizar-el-sistema) |
| No resuelve dominios                             | `resolvectl flush-caches`; revisar `/etc/resolv.conf`                             | — |

## Teclado y trackpad

| Problema                                        | Solución rápida                                                                 | Detalle |
| ----------------------------------------------- | ------------------------------------------------------------------------------- | ------- |
| `⌥2` escribe `"` en vez de `@`                   | `setxkbmap -query`; reinstalar la variante `es(mac)`                             | [Teclado](../06-hardware-macbook/teclado-mac.md) |
| El teclado volvió al layout PC tras actualizar   | `xkb-data` borró la variante: `sudo bash scripts/hardware/wifi-helper/instalar-teclado-mac.sh` | [Teclado](../06-hardware-macbook/teclado-mac.md#se-perdió-después-de-actualizar) |
| `⌘` no copia/pega                                | Falta `ctrl:swap_lwin_lctl` en las opciones                                      | [Teclado](../06-hardware-macbook/teclado-mac.md#-command--ctrl) |
| `Alt+Tab` no cambia de ventana                   | Es normal (`Option` = AltGr); usar `⌘Tab`                                        | [Atajos](../04-productividad/atajos.md) |
| El clic derecho abre en la esquina               | `gsettings set org.cinnamon.desktop.peripherals.touchpad click-method 'fingers'` | [Trackpad](../06-hardware-macbook/trackpad.md) |
| El cursor salta al escribir                      | Activar `disable-while-typing`                                                   | [Trackpad](../06-hardware-macbook/trackpad.md) |
| El trackpad no responde tras suspender           | `sudo modprobe -r bcm5974 && sudo modprobe bcm5974`                              | [Trackpad](../06-hardware-macbook/trackpad.md) |

## Audio

| Problema                                        | Solución rápida                                                                 | Detalle |
| ----------------------------------------------- | ------------------------------------------------------------------------------- | ------- |
| LED rojo fijo dentro del jack de audífonos       | No es una falla: es el láser óptico S/PDIF. `sudo bash scripts/hardware/apagar-led-optico.sh --instalar` | [LED óptico](../06-hardware-macbook/led-optico.md) |
| El LED vuelve a encenderse al reiniciar          | El autostart no corrió: `sudo -n /usr/local/lib/linux-mint/apagar-led-optico.sh` | [LED óptico](../06-hardware-macbook/led-optico.md#solución-permanente) |
| No se oye nada con audífonos conectados          | `alsamixer` → `F6` → CS4206 → subir **Headphone**; o `pavucontrol`               | [LED óptico](../06-hardware-macbook/led-optico.md) |
| El audio sale por HDMI u óptico en vez de bocinas | `pactl set-card-profile alsa_card.pci-0000_00_1b.0 output:analog-stereo+input:analog-stereo` | [LED óptico](../06-hardware-macbook/led-optico.md) |

## Escritorio

| Problema                                        | Solución rápida                                                                 | Detalle |
| ----------------------------------------------- | ------------------------------------------------------------------------------- | ------- |
| Cinnamon se queda congelado                      | `Ctrl+Alt+Esc` o `cinnamon --replace &`                                          | [Preferencias](../01-sistema/preferencias.md) |
| Se perdió el panel o los applets                 | `dconf load /org/cinnamon/ < dotfiles/cinnamon/dconf-cinnamon.ini`               | [Preferencias](../01-sistema/preferencias.md) |
| Los atajos `⌘Q`, `⌘M`… no hacen nada              | `bash dotfiles/cinnamon/atajos-mac.sh`                                           | [Atajos](../04-productividad/atajos.md) |
| No hay sonido                                    | `pavucontrol` → *Playback*; `alsamixer` y subir volumen                          | — |
| El brillo no cambia                              | `xbacklight -inc 10`; revisar `F1`/`F2` en `Preferencias → Teclado`               | [Hardware](../06-hardware-macbook/) |
| El Bluetooth no aparece                          | `systemctl restart bluetooth`; `rfkill unblock bluetooth`                        | — |
| La hora está mal                                 | `sudo timedatectl set-ntp true`; zona: `America/Mexico_City`                      | — |

## Aplicaciones

| Problema                                        | Solución rápida                                                                 | Detalle |
| ----------------------------------------------- | ------------------------------------------------------------------------------- | ------- |
| Brave no arranca tras actualizar                 | `sudo apt-get install -f`, luego `--reinstall install brave-browser`             | [Apps](../02-aplicaciones/README.md) |
| Error de clave GPG de Brave                      | Reimportar la clave y regenerar el `.list`                                       | [Apps](../02-aplicaciones/README.md#brave-browser) |
| Netflix/Spotify no reproducen                    | Activar Widevine y reiniciar el navegador                                        | [Navegadores](../04-productividad/navegadores.md) |
| Los enlaces se abren en el navegador equivocado  | `xdg-settings set default-web-browser brave-browser.desktop`                     | [Navegadores](../04-productividad/navegadores.md#cambiar-el-navegador-predeterminado) |
| RustDesk se queda en "esperando imagen"          | `bash dotfiles/rustdesk/video.sh` y revisar el equipo remoto                      | [RustDesk](../07-rustdesk/problemas.md) |
| RustDesk dice "connection is not allowed"        | Iniciar sesión en RustDesk (servidor público)                                    | [RustDesk](../07-rustdesk/problemas.md#the-connection-is-not-allowed) |
| RustDesk no da audio                             | Activar el altavoz en la barra de la sesión; revisar `pavucontrol`               | [RustDesk](../07-rustdesk/problemas.md#audio-no-funciona) |

## Arranque y sistema

| Problema                                        | Solución rápida                                                                 | Detalle |
| ----------------------------------------------- | ------------------------------------------------------------------------------- | ------- |
| Pantalla negra después de actualizar             | En GRUB elegir el kernel anterior (`6.14.0-37`)                                  | [Sistema](../01-sistema/README.md#kernel-y-arranque) |
| El equipo no arranca                            | `Ctrl+Alt+F2` para consola; `sudo apt-get install -f`; revisar `journalctl -xb`   | — |
| Se agota la batería muy rápido                   | Batería al ~29 %: reemplazarla (A1322)                                           | [Hardware](../06-hardware-macbook/#batería) |
| Se calienta y el ventilador hace ruido           | Limpiar ventilador, `sensors`, revisar procesos con `htop`                        | [Hardware](../06-hardware-macbook/#ventilación-y-temperatura) |
| El sistema va lento                              | `systemd-analyze blame`, `htop`, desactivar efectos de Cinnamon                   | — |

## Cómo pedir ayuda con contexto

```bash
# Resumen del sistema
inxi -Fz 2>/dev/null || neofetch

# Logs del arranque
journalctl -xb -p err --no-pager | tail -50

# Estado del WiFi
nmcli device status; dmesg | grep -iE 'wl|b43|bcma' | tail -20

# Estado de RustDesk
bash dotfiles/rustdesk/estado.sh
```

> Revisa siempre los logs antes de compartirlos: pueden contener IPs, IDs o rutas personales.

## Volver a empezar

Si algo quedó muy roto, el repo permite reaplicar la configuración sin formatear:

```bash
cd ~/Documentos/GitHub/linux-mint
git pull
./install.sh
```

Los scripts son idempotentes y guardan respaldos `*.bak-<fecha>` antes de sobrescribir. Y si toca formatear, el README tiene la guía completa desde cero.
