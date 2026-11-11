# 06 · Hardware MacBook

El MacBook Pro A1278 (2012) necesita ajustes especiales en Linux. Esta sección documenta los tres que dieron más guerra: **WiFi Broadcom**, **teclado español de Apple** y **trackpad**.

## Estado del hardware

| Componente        | Modelo / ID                          | Estado en Linux Mint 22.3          |
| ----------------- | ------------------------------------ | ---------------------------------- |
| WiFi              | Broadcom BCM4331 `[14e4:4331]`       | funciona con driver propietario `wl` |
| Ethernet          | Broadcom NetXtreme `[14e4:16b4]`     | funciona con `tg3`                 |
| Teclado           | Apple Internal Keyboard / Trackpad   | variante `es(mac)` propia          |
| Trackpad          | `bcm5974`                            | multitáctil y clic derecho a 2 dedos |
| Bluetooth         | Broadcom BCM2046                     | funciona con Blueberry             |
| Cámara (iSight)   | Apple FaceTime HD                    | funciona con `uvcvideo`            |
| Lector SD         | Apple SD Card Reader                 | funciona                           |
| Batería           | `BAT0`                               | ~29 % de capacidad (desgastada)    |

## Contenido

- [WiFi BCM4331](wifi-bcm4331.md) — driver `wl`, DKMS, 5 GHz y recuperación.
- [Teclado Mac español](teclado-mac.md) — variante `es(mac)` y símbolos Option.
- [Trackpad](trackpad.md) — clic derecho a dos dedos y gestos.

## Batería

```bash
upower -i $(upower -e | grep BAT)
```

- Capacidad de diseño: **63.2 Wh**; capacidad actual: **18.2 Wh** (~29 %).
- Sirve para emergencias; para trabajar hay que usar el cargador.
- Si se quiere cambiar: es una batería A1322 con adhesivo; requiere destornillador de seguridad y paciencia. No es una reparación de 10 minutos.

## Ventilación y temperatura

El A1278 calienta y el ventilador se oye con facilidad. Para vigilar:

```bash
sudo apt-get install -y lm-sensors
sudo sensors-detect --auto
watch -n 2 sensors
```

- Limpiar el ventilador y cambiar la pasta térmica cada 2-3 años.
- `thermald` e `intel-microcode` ayudan a gestionar la temperatura; ambos están instalados.
- Evitar dejarlo sobre la cama o superficies blandas.

## Teclas de función

`F1`/`F2` controlan el brillo y `F11`/`F12` el volumen. Si `F1`–`F12` actúan como funciones en vez de teclas multimedia, cambia el comportamiento en `Preferencias → Teclado → Distribución → Opciones → Teclas de función`.

## Siguiente paso

[07 · RustDesk](../07-rustdesk/) → acceso remoto a este equipo y desde este equipo.
