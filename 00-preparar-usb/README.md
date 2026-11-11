# 00 · Preparar la USB con Linux Mint

> Paso previo a todo. Se hace **antes** de formatear el MacBook y no necesita Linux instalado.

Esta guía deja un USB arrancable con **Linux Mint 22.3 “Zena” Cinnamon 64-bit** para el MacBook Pro A1278. Al final de la página está el arranque desde el Mac y la instalación.

## 1. Lo que necesitas

| Material                    | Detalle                                                        |
| --------------------------- | -------------------------------------------------------------- |
| USB                         | **4 GB mínimo**, 8 GB o más recomendado. **Se borra completo.** |
| Imagen ISO                  | Linux Mint 22.3 Cinnamon 64-bit (~2.9 GB)                       |
| Otro equipo                 | Para crear la USB: este Mint, otro Linux, macOS o Windows       |
| Cable Ethernet              | **Muy importante en este MacBook** (ver aviso más abajo)        |
| Cargador                    | El MacBook no aguanta una instalación con batería al 29 %       |
| Respaldo                    | Tus archivos personales ya deben estar fuera del equipo         |

> ⚠️ **El WiFi Broadcom BCM4331 no funciona en la sesión live ni en una instalación recién hecha.** El driver propietario `wl` se instala después con este repo, y para descargarlo hace falta internet. Por eso: **conecta el cable Ethernet** (funciona de fábrica con el driver `tg3`) o usa tethering USB del teléfono.

## 2. Descargar la ISO

Descarga directa (mirror oficial de kernel.org):

```bash
cd ~/Descargas
curl -fLO https://mirrors.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso
```

Alternativas:

- Página oficial: <https://linuxmint.com/download.php>
- Torrent: <https://linuxmint.com/torrents/linuxmint-22.3-cinnamon-64bit.iso.torrent>
- Si el equipo es muy antiguo y la ISO normal no arranca: <https://linuxmint.com/hwe.php>

### Verificar la descarga (obligatorio)

```bash
cd ~/Descargas

# Descargar la lista oficial de hashes
curl -fLO https://mirrors.kernel.org/linuxmint/stable/22.3/sha256sum.txt

# Comparar (Linux)
sha256sum -c --ignore-missing sha256sum.txt

# Comparar (macOS)
shasum -a 256 linuxmint-22.3-cinnamon-64bit.iso
# y mirar a mano la línea del archivo en sha256sum.txt
```

Debe decir `linuxmint-22.3-cinnamon-64bit.iso: OK`. Si no coincide, vuelve a descargarla: una ISO corrupta produce instalaciones rotas o un USB que no arranca.

## 3. Crear la USB

### Opción A — Desde Linux Mint (la más fácil)

**Interfaz gráfica:** inserta la USB → abre **USB Image Writer** (`mintstick`) → selecciona la ISO → selecciona la USB → **Escribir**.

**Terminal:**

```bash
# 1. Identificar la USB (NO la confundas con el disco del sistema)
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS

# 2. Desmontar sus particiones (ejemplo: /dev/sdb1)
sudo umount /dev/sdb1 2>/dev/null || true

# 3. Escribir la ISO en el DISCO COMPLETO (ejemplo: /dev/sdb, sin número)
sudo dd if=~/Descargas/linuxmint-22.3-cinnamon-64bit.iso \
        of=/dev/sdb bs=4M status=progress oflag=sync

# 4. Sincronizar y expulsar
sync
sudo eject /dev/sdb
```

> ⚠️ `of=/dev/sdb` es el **disco**, no `/dev/sdb1` (la partición). Si te equivocas de dispositivo borras tus datos. Revisa dos veces `lsblk`.

### Opción B — Desde macOS

**Interfaz gráfica:** [balenaEtcher](https://etcher.balena.io/) → *Flash from file* → elige la ISO → elige la USB → *Flash*.

**Terminal:**

```bash
# 1. Ver los discos; identifica la USB por su tamaño (ej. disk4)
diskutil list

# 2. Desmontar (sin expulsar) la USB
diskutil unmountDisk /dev/disk4

# 3. Escribir (rdisk = acceso raw, mucho más rápido)
sudo dd if=~/Downloads/linuxmint-22.3-cinnamon-64bit.iso of=/dev/rdisk4 bs=1m

# 4. Progreso: pulsa Ctrl+T mientras corre
# 5. Expulsar al terminar
diskutil eject /dev/disk4
```

> En macOS el dispositivo es `disk4` / `rdisk4`; no uses `disk4s1`.

### Opción C — Desde Windows

- **Rufus**: selecciona la ISO, esquema **GPT**, destino **UEFI (no CSM)**, sistema de archivos FAT32 → *Empezar*.
- O **balenaEtcher**, que hace lo mismo con menos preguntas.

## 4. Arrancar el MacBook desde la USB

1. Apaga el MacBook por completo.
2. Conecta la USB (mejor en el puerto **izquierdo**, junto al MagSafe).
3. Enciende y mantén pulsada **Option (⌥)** hasta que aparezca el selector de arranque.
4. Elige **EFI Boot** (icono naranja/amarillo). Si solo aparece el disco interno, apaga y repite.
5. En el menú de Mint elige **Start Linux Mint** (sesión live).
6. Conecta el **cable Ethernet** antes de instalar.

### Si la USB no aparece en el selector

| Causa probable                        | Solución                                                           |
| ------------------------------------- | ------------------------------------------------------------------ |
| La USB no se escribió bien            | Repetir con Etcher o `dd`; comprobar que la ISO es válida          |
| Puerto USB 3 problemático             | Probar el otro puerto, o una USB 2.0                                |
| Firmware con NVRAM rara               | Reiniciar con `⌘ + ⌥ + P + R` (reset NVRAM) y volver a probar      |
| La ISO normal no arranca en el A1278  | Probar la **HWE ISO** de Linux Mint                                 |
| USB con tabla de particiones rara     | Usar Rufus en modo GPT/UEFI o `dd` (la ISO es híbrida)              |

## 5. Instalar Linux Mint

En la sesión live:

1. Doble clic en **Install Linux Mint**.
2. Idioma: **Español (México)**; teclado: **Spanish (Macintosh)** si aparece, si no **Spanish**.
3. Marcar **Install multimedia codecs**.
4. Tipo de instalación: **Erase disk and install Linux Mint** (borra macOS y todo el disco).
5. Aceptar el esquema de particiones que propone el instalador:
   - `EFI` de ~512 MB (FAT32)
   - `/` ext4 con el resto del disco
6. Zona horaria: **America/Mexico_City**.
7. Usuario: `yorbimv` (misma ruta que este repo) y una contraseña que recuerdes.
8. Terminar y **reiniciar**; retira la USB cuando lo pida.

> El MacBook A1278 no tiene Secure Boot, así que no hay que firmar nada ni desactivarlo en la BIOS.

### Si el instalador no crea bien el arranque EFI

Algunos A1278 necesitan hacer las particiones a mano. En ese caso:

| Partición | Tamaño    | Tipo       | Punto de montaje |
| --------- | --------- | ---------- | ---------------- |
| 1         | 512 MB    | FAT32      | `/boot/efi`      |
| 2         | Resto     | ext4       | `/`              |

Y en el instalador elegir **Something else** en vez de borrar el disco. El gestor de arranque debe instalarse en `/dev/sda` (el disco interno), no en la USB.

## 6. Primer arranque

1. Deja el **cable Ethernet** conectado.
2. Entra a Linux Mint y abre una terminal.
3. Actualiza e instala Git:

   ```bash
   sudo apt-get update
   sudo apt-get install -y git curl
   ```

4. Clona este repo y ejecuta el instalador:

   ```bash
   git clone https://github.com/yorbimv/linux-mint.git ~/Documentos/GitHub/linux-mint
   cd ~/Documentos/GitHub/linux-mint
   ./install.sh
   ```

5. El paso **05-wifi** instala el driver `wl`; reinicia al terminar y ya podrás desconectar el cable.
6. Sigue los pasos **06** a **11** para teclado, trackpad, atajos, apps y RustDesk.

## 7. Checklist antes de formatear

- [ ] Archivos personales respaldados (nube o disco externo)
- [ ] Este repo está actualizado en GitHub (`git push`)
- [ ] ISO descargada y **verificada** con SHA256
- [ ] USB escrita y probada en el selector de arranque
- [ ] Cable Ethernet a mano
- [ ] Cargador conectado
- [ ] Contraseña de usuario decidida

## Siguiente paso

[01 · Sistema](../01-sistema/) → actualizar, drivers y preferencias.
