# 01 · Sistema

> Linux Mint 22.3 (Zena) · kernel 7.0.0-42 · Cinnamon 6.6.9 · sesión X11

Aquí está lo que se tocó del sistema base: actualizaciones, drivers, servicios y preferencias del escritorio. El paso `01-actualizar` de `install.sh` hace lo mismo de forma automática.

## Resumen del equipo

| Dato        | Valor                                              |
| ----------- | -------------------------------------------------- |
| Equipo      | MacBook Pro 13" A1278 (2012)                       |
| CPU         | Intel Core i5-3210M @ 2.50 GHz                     |
| RAM         | 15 GB                                              |
| Disco       | SSD 477 GB (`HS-SSD-WAVE(S) 512G`)                 |
| Gráfica     | Intel HD Graphics 4000                             |
| WiFi        | Broadcom BCM4331 `[14e4:4331]` → driver `wl`       |
| Escritorio  | Cinnamon 6.6.9 sobre X11 (`1:0:bottom`)            |
| Hostname    | `macbookpro`                                       |
| Batería     | `BAT0`, ~29 % de capacidad de diseño (desgastada)  |

## Actualizar el sistema

> ⚠️ **En una instalación nueva todavía no hay WiFi.** Conecta el cable Ethernet, actualiza y descarga el driver BCM4331 desde la web; hasta entonces la única red es el cable. Ver [06 · WiFi BCM4331](../06-hardware-macbook/wifi-bcm4331.md).

```bash
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y autoremove --purge
sudo apt-get -y autoclean
```

- `apt` en Linux Mint es un *wrapper* en `/usr/local/bin/apt`. En scripts conviene usar `apt-get` para evitar el modo interactivo.
- El servicio `mint-refresh-ca` bloquea `/var/lib/apt/lists/lock` al arrancar. Los scripts esperan con `fuser` antes de instalar; `DPkg::Lock::Timeout` **no** cubre ese bloqueo.
- Si hay `/var/run/reboot-required`, reinicia antes de tocar drivers.

## Drivers y DKMS

| Componente            | Paquete                          | Estado        |
| --------------------- | -------------------------------- | ------------- |
| WiFi Broadcom BCM4331 | `broadcom-sta-dkms` (`wl`)       | activo        |
| Cabeceras del kernel  | `linux-headers-generic-hwe-24.04`| instaladas    |
| Microcódigo Intel     | `intel-microcode` / `amd64-microcode` | instalados |

El módulo `wl` se compila con DKMS para **cada kernel**:

```bash
dkms status
sudo dkms autoinstall
```

Detalle completo en [06 · Hardware MacBook](../06-hardware-macbook/).

## Servicios relevantes

```bash
systemctl is-active rustdesk.service   # acceso remoto
systemctl status bluetooth             # Bluetooth
timedatectl                            # hora y zona (America/Mexico_City)
```

- **RustDesk** queda `enabled` (arranca con el equipo) — ver [07 · RustDesk](../07-rustdesk/).
- **Bluetooth** funciona con el chip Apple; se administra con Blueberry (`blueman`).
- **Timeshift** está instalado para instantáneas del sistema. Configúralo en `Menú → Timeshift` (RSYNC, semanal, 3 copias).

## Preferencias del escritorio

Los ajustes reales de Cinnamon (tema, iconos, panel, fondo, efectos, trackpad y energía) están en [preferencias.md](preferencias.md). Se pueden volcar y restaurar con `dconf`:

```bash
dconf dump /org/cinnamon/ > mi-cinnamon.ini
dconf load /org/cinnamon/ < mi-cinnamon.ini
```

> `./scripts/guardar.sh` actualiza ese volcado en el repo con la configuración actual.

## Kernel y arranque

- Kernel en uso: `7.0.0-42-generic` (HWE de Ubuntu 24.04).
- También hay DKMS compilado para `6.14.0-37-generic`, por si eliges el kernel anterior en GRUB.
- El arranque es UEFI con GRUB normal; no hay Secure Boot activo (por eso el módulo `wl` propietario carga sin firma).

## Siguiente paso

[02 · Aplicaciones](../02-aplicaciones/) → instalar las apps y utilidades.
