# 02 · Aplicaciones

Todo lo que está instalado fuera de lo que trae Linux Mint de fábrica. El paso `09-apps` de `install.sh` reproduce esta sección.

## Resumen

| Aplicación          | Versión        | Origen                          |
| ------------------- | -------------- | ------------------------------- |
| Brave Browser       | 1.99.55        | repo apt oficial de Brave       |
| Firefox             | 159.0.1        | repos de Linux Mint             |
| Thunderbird         | 153.6.0esr     | repos de Linux Mint             |
| RustDesk            | 1.5.1          | `.deb` oficial de GitHub        |
| Celluloid           | 0.21           | repos de Linux Mint             |
| Drawing             | —              | repos de Linux Mint             |
| Xviewer / Pix       | —              | repos de Linux Mint             |
| Xed / Xreader       | —              | repos de Linux Mint             |
| File Roller         | —              | repos de Linux Mint             |
| Timeshift           | 25.12.4        | repos de Linux Mint             |
| Hypnotix            | —              | repos de Linux Mint             |
| Warpinator          | —              | repos de Linux Mint             |
| Web App Manager     | —              | repos de Linux Mint             |

No hay paquetes **Flatpak** ni **Snap** instalados: todo lo de este equipo viene de `apt` o de un `.deb` oficial.

## Brave Browser

Se instaló desde el repositorio oficial (así se actualiza solo con `apt`):

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
  | sudo tee /etc/apt/keyrings/brave-browser-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
  | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt-get update && sudo apt-get install -y brave-browser
```

- La clave y el `.list` están guardados en [`paquetes/brave-browser-release.list`](../paquetes/brave-browser-release.list).
- Script completo: [`scripts/apps/brave.sh`](../scripts/apps/brave.sh).
- Es el **navegador predeterminado** del sistema.
- Perfil sincronizado con la cuenta de Brave; extensiones y marcadores se recuperan al iniciar sesión.

Verificación:

```bash
brave-browser --version
apt-cache policy brave-browser
```

## Firefox

```bash
sudo apt-get install -y firefox firefox-locale-es firefox-locale-en
```

- Se mantiene como navegador secundario (cuentas de trabajo, perfiles aislados).
- El idioma de la interfaz se cambia en `about:preferences → General → Language`.

## RustDesk

No viene de un repositorio apt: se instala desde el `.deb` oficial de GitHub para tener siempre la última versión.

```bash
sudo bash scripts/apps/rustdesk.sh
```

Instalación, servicio, ajustes de vídeo y diagnóstico en [07 · RustDesk](../07-rustdesk/).

## Utilidades del sistema

| Paquete            | Para qué sirve                                  |
| ------------------ | ----------------------------------------------- |
| `7zip`             | Comprimir/descomprimir `.7z`, `.zip`, `.rar`    |
| `file-roller`      | Abrir comprimidos desde Nemo                    |
| `baobab`           | Ver qué ocupa espacio en el disco               |
| `bulky`            | Renombrar muchos archivos a la vez              |
| `exfat-fuse` + `exfatprogs` | Tarjetas SD y USB en exFAT              |
| `ntfs-3g`          | Discos y USB en NTFS (Windows)                  |
| `ffmpegthumbnailer`| Miniaturas de vídeo en Nemo                     |
| `timeshift`        | Instantáneas del sistema                        |
| `warpinator`       | Compartir archivos con otros equipos en la LAN  |
| `webapp-manager`   | Convertir sitios web en "apps" del menú         |
| `neofetch`         | Resumen del sistema en la terminal              |

La lista completa está en [`paquetes/apt-extra.txt`](../paquetes/apt-extra.txt) y se instala con:

```bash
sudo apt-get install -y $(grep -vE '^\s*(#|$)' paquetes/apt-extra.txt | tr '\n' ' ')
```

## Multimedia

- **Celluloid** — reproductor basado en MPV. Es el predeterminado para vídeo.
- **Hypnotix** — listas IPTV; no trae canales, se añaden listas M3U.
- **Drawing** — editor de imágenes sencillo para capturas y anotaciones.
- **Xviewer / Pix** — visor de fotos (Xviewer es el predeterminado para abrir imágenes).

## Añadir una aplicación nueva

1. Si está en los repos: `sudo apt-get install -y paquete` y añádela a `paquetes/apt-extra.txt`.
2. Si es un `.deb` oficial: crea un script en `scripts/apps/` siguiendo `brave.sh` o `rustdesk.sh` (descarga, verifica, `apt-get install -y ./archivo.deb`).
3. Si es Flatpak: instálalo y luego `flatpak list --app --columns=application,version > paquetes/flatpak.txt`.
4. Documenta la app en esta página y ejecuta `./scripts/guardar.sh`.

## Siguiente paso

[03 · Dev Environment](../03-dev-environment/) → git, GitHub CLI y OpenCode.
