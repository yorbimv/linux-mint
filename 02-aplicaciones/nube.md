# Nube: Google Drive (3 cuentas) y OneDrive

Las carpetas `~/Google Drive`, `~/Google Drive 2`, `~/Google Drive 3` y `~/OneDrive` aparecen en el panel lateral de **Nemo** y muestran tus archivos en la nube.

> Instalado en `~/.local/bin` **sin sudo** porque en este equipo el diálogo de zenity para la contraseña de sudo no responde. `~/.profile` ya añade `~/.local/bin` al `PATH` en sesiones nuevas; en el shell actual usa la ruta absoluta.

## Resumen

| Nube | Remote | Carpeta | Servicio (systemd --user) | Estado |
| ---- | ------ | ------- | ------------------------- | ------ |
| Google Drive (cuenta 1) | `gdrive` | `~/Google Drive` | `rclone-gdrive.service` | active + enabled |
| Google Drive (cuenta 2) | `gdrive2` | `~/Google Drive 2` | `rclone-gdrive2.service` | active + enabled |
| Google Drive (cuenta 3) | `gdrive3` | `~/Google Drive 3` | `rclone-gdrive3.service` | active + enabled |
| OneDrive | `onedrive` | `~/OneDrive` | `rclone-onedrive.service` | active + enabled |

Todas son carpetas **FUSE montadas bajo demanda** con rclone: los archivos están en la nube y se descargan al abrirlos (no ocupan espacio local). Configuración en `~/.config/rclone/rclone.conf` (permisos `600`, contiene los tokens — **no subir al repo**).

## Google Drive (rclone v1.76.0)

- Binario: `~/.local/bin/rclone`
- Cuenta 1: remote `gdrive` → `~/Google Drive`
- Cuenta 2: remote `gdrive2` → `~/Google Drive 2`
- Cuenta 3: remote `gdrive3` → `~/Google Drive 3`
- Todos: `type = drive`, `scope = drive`, `team_drive =`

### Verificar

```bash
systemctl --user status rclone-gdrive.service
mount | grep 'Google Drive'
ls "$HOME/Google Drive"
```

### Repetir la autorización

```bash
~/.local/bin/rclone authorize drive
```

Inicia sesión y pega el token en `rclone.conf` en una sola línea para `token`:

```ini
[gdrive]
type = drive
scope = drive
token = {"access_token":"...","refresh_token":"...","token_type":"Bearer","expiry":"..."}
team_drive =
```

Luego `chmod 600 ~/.config/rclone/rclone.conf` y `systemctl --user restart rclone-gdrive.service`.

### Segunda cuenta de Google Drive

Para añadir otra cuenta se repite el proceso con un remote con otro nombre (`gdrive2`, `gdrive3`…) y su propia carpeta y servicio. **Usa «Usar otra cuenta» en el navegador** para no autorizar la misma cuenta dos veces.

```bash
~/.local/bin/rclone authorize drive
# Inicia sesión con la OTRA cuenta y pega el token como [gdrive2] en rclone.conf
mkdir -p "$HOME/Google Drive 2"
```

Servicio `~/.config/systemd/user/rclone-gdrive2.service` (igual que `rclone-gdrive.service` pero con `gdrive2:` y `"%h/Google Drive 2"`):

```bash
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive2.service
```

Añadir bookmark: `file:///home/yorbimv/Google%20Drive%202` en `~/.config/gtk-3.0/bookmarks`.

Para la **tercera cuenta** se repite con `gdrive3` y `~/Google Drive 3` (servicio `rclone-gdrive3.service`).

> **Cómo saber si es cuenta distinta:** Google emite un `refresh_token` nuevo en cada autorización, así que comparar tokens no sirve. Compara los **IDs de archivo**: `rclone lsjson gdrive: --max-depth 1` contra `rclone lsjson gdrive3: --max-depth 1`. Si los IDs coinciden, autorizaste la misma cuenta otra vez. (Las carpetas compartidas entre cuentas pueden aparecer con el mismo ID; busca un archivo propio distinto.)
>
> ⚠️ rclone avisa de que su `client_id` compartido se retira en 2026. Si deja de conectar, crea un `client_id` propio en Google Cloud y añade `client_id` / `client_secret` al remote ([docs](https://rclone.org/drive/#making-your-own-client-id)).

### Instalación reproducible

```bash
bash scripts/apps/google-drive.sh
```

## OneDrive (rclone v1.76.0)

- Remote: `onedrive` (`type = onedrive`, `drive_type = personal`, `drive_id = ...`)
- Montaje: `~/OneDrive`
- Cuenta: **personal** (outlook.com / hotmail.com / live.com)

### Por qué no se usa el paquete `onedrive` de Ubuntu

El cliente `onedrive 2.4.25` de los repos de Ubuntu usa un `client_id` viejo: Microsoft redirige a `https://login.microsoftonline.com/common/wrongplace` (página incorrecta) y **nunca entrega el código**. Además necesita librerías D que no se pudieron instalar con apt. Se descartó y se usa rclone, que funciona igual que con Google Drive.

### Verificar

```bash
systemctl --user status rclone-onedrive.service
mount | grep 'OneDrive'
ls "$HOME/OneDrive"
```

### Repetir la autorización

```bash
~/.local/bin/rclone authorize onedrive
```

Pega el token en `rclone.conf`:

```ini
[onedrive]
type = onedrive
token = {"access_token":"...","refresh_token":"...","token_type":"Bearer","expiry":"..."}
drive_type = personal
drive_id = 8B17D36930131494
```

Si falta `drive_id`, rclone dice *"unable to get drive_id and drive_type"*. Se obtiene con el `access_token` del propio token:

```bash
curl -sS -H "Authorization: Bearer $TOKEN" https://graph.microsoft.com/v1.0/me/drive
```

y se copia el campo `id` en `drive_id`.

### Instalación reproducible

```bash
bash scripts/apps/onedrive.sh
```

## Bookmarks de Nemo

Ambas carpetas están en `~/.config/gtk-3.0/bookmarks`:

```
file:///home/yorbimv/Google%20Drive
file:///home/yorbimv/Google%20Drive%202
file:///home/yorbimv/Google%20Drive%203
file:///home/yorbimv/OneDrive
```

Si una ventana de Nemo abierta **antes del montaje** sigue mostrando la carpeta vacía, ciérrala y vuelve a abrirla (Nemo cachea el listado). Si no aparecen en el panel, reinicia Nemo (`pkill nemo; nemo &`) o recarga Cinnamon (`Ctrl+Alt+Esc`).
