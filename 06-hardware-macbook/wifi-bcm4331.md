# WiFi Broadcom BCM4331

> Tarjeta: `02:00.0 Network controller [0280]: Broadcom Inc. BCM4331 802.11a/b/g/n [14e4:4331] (rev 02)`
> Interfaz: `wlp2s0` · Driver: `wl` (`broadcom-sta-dkms`)

Es el punto más delicado del equipo. El driver libre `b43` funciona a medias (2.4 GHz, enlaces inestables, sin 5 GHz); el propietario `wl` da 5 GHz y velocidad completa, pero **hay que recompilarlo con DKMS en cada kernel nuevo**.

## Instalación

> ⚠️ **Sin WiFi todavía:** el paquete `broadcom-sta-dkms` y sus cabeceras se descargan de internet. En una instalación nueva conecta el **cable Ethernet** (funciona de fábrica con `tg3`) y no lo desconectes hasta que `ip route get 1.1.1.1` salga por `wlp2s0`.

```bash
# Con Ethernet conectado
sudo apt-get update
sudo apt-get install -y dkms linux-headers-generic-hwe-24.04

sudo bash scripts/hardware/wifi-bcm4331.sh
sudo reboot
```

El script:

1. Actualiza índices de `apt`.
2. Instala `broadcom-sta-dkms` y comprueba que DKMS reporta el módulo para el kernel en uso.
3. Si `wl` compiló bien, bloquea los módulos que compiten por la tarjeta:
   `b43`, `b43legacy`, `ssb`, `bcma`, `brcm80211`, `brcmsmac`, `brcmfmac`.
4. Regenera el initramfs.
5. Descarga los módulos en conflicto y carga `wl`.
6. Desbloquea la radio (`rfkill`).
7. Muestra el estado final.

Si `wl` **no** compila, el script cae automáticamente al driver libre `b43` con `firmware-b43-installer` para no dejar el equipo sin WiFi.

## Comprobar que funciona

```bash
lspci -k -s 02:00.0        # debe decir: Kernel driver in use: wl
lsmod | grep '^wl '
nmcli device status        # wlp2s0: wifi  connected
iw dev wlp2s0 info         # canal y banda (5 GHz = canales 36-165)
ip route get 1.1.1.1       # debe salir por wlp2s0
```

## 5 GHz

```bash
nmcli -f SSID,CHAN,FREQ,RATE,SIGNAL device wifi list
```

- Preferir redes de 5 GHz: menos interferencia y más velocidad.
- El BCM4331 soporta 802.11 a/b/g/n; **no** tiene 802.11ac (WiFi 5). La velocidad máxima realista ronda 300 Mbps.
- El driver `wl` **no** soporta modo monitor ni punto de acceso.

## Prioridad WiFi sobre cable

El equipo usa el WiFi como ruta principal y deja el cable (`enp1s0f0`) como respaldo. NetworkManager lo resuelve con métricas:

```bash
# WiFi: prioridad alta y métrica baja
nmcli connection modify "MI-WIFI" connection.autoconnect-priority 100 ipv4.route-metric 50 ipv6.route-metric 50

# Cable: prioridad baja y métrica alta
nmcli connection modify "Wired connection 1" connection.autoconnect-priority 0 ipv4.route-metric 200 ipv6.route-metric 200

nmcli connection up "MI-WIFI"
```

> Cambia `"MI-WIFI"` por el nombre real de tu conexión (`nmcli -t -f NAME,TYPE connection show`). El script `scripts/hardware/wifi-helper/wifi-principal.sh` trae un ejemplo con la red de casa; edítalo antes de usarlo en otro sitio.

## Actualizaciones de kernel

Cada kernel nuevo requiere recompilar `wl`:

```bash
sudo apt-get install -y linux-headers-$(uname -r)
sudo dpkg-reconfigure broadcom-sta-dkms
# o simplemente:
sudo dkms autoinstall
dkms status
```

Si tras reiniciar no aparece `wlp2s0`:

```bash
sudo modprobe wl
dmesg | tail -30
dkms status
```

## Recuperación sin WiFi

Si el driver falla y no hay red, estas son las salidas:

1. **Cable Ethernet** al puerto del MacBook (funciona con `tg3` sin configurar nada).
2. **Tethering USB** del teléfono (aparece como `usb0`/`enp0s...`).
3. **Driver libre temporal**:

   ```bash
   sudo apt-get install -y firmware-b43-installer
   sudo sed -i 's/^blacklist b43/#blacklist b43/' /etc/modprobe.d/blacklist-bcm4331.conf
   sudo modprobe -r wl && sudo modprobe b43
   ```

4. Descargar el `.deb` en otro equipo y pasarlo por USB:

   ```bash
   # en el otro equipo (misma arquitectura amd64 y misma versión de Mint)
   apt-get download broadcom-sta-dkms
   # en el MacBook
   sudo apt-get install -y ./broadcom-sta-dkms_*.deb
   ```

## Problemas frecuentes

| Síntoma                                        | Causa / solución                                                        |
| ---------------------------------------------- | ----------------------------------------------------------------------- |
| No existe `wlp2s0` tras actualizar              | DKMS no compiló para el kernel nuevo → `sudo dkms autoinstall`          |
| `wl` carga pero no conecta                      | `rfkill list`; `sudo rfkill unblock all`; revisar contraseña en NetworkManager |
| Solo aparecen redes de 2.4 GHz                  | La tarjeta está en 2.4 GHz o el AP no anuncia 5 GHz; revisar canal      |
| Velocidad muy baja                              | Señal, canal saturado o driver `b43` en uso (`lspci -k`)                 |
| `ERROR: could not insert 'wl'`                  | Otro módulo tomó la tarjeta: `sudo modprobe -r b43 ssb bcma`            |
| El equipo se desconecta al suspender            | `sudo modprobe -r wl && sudo modprobe wl` o reiniciar NetworkManager    |
| `apt` se queda esperando                       | `mint-refresh-ca` tiene el lock; esperar o `sudo systemctl stop mint-refresh-ca` |

## Archivos que toca

| Archivo                                        | Contenido                                  |
| ---------------------------------------------- | ------------------------------------------ |
| `/etc/modprobe.d/blacklist-bcm4331.conf`       | Bloqueo de `b43`/`ssb`/`bcma`/`brcm*`      |
| `/etc/modprobe.d/broadcom-sta-dkms.conf`       | Blacklist que trae el propio paquete       |
| `/lib/modules/$(uname -r)/updates/dkms/wl.ko`  | Módulo compilado                            |
| `/etc/NetworkManager/system-connections/`      | Perfiles de red (contienen contraseñas)     |

> Los perfiles de NetworkManager **no** se versionan en el repo.
