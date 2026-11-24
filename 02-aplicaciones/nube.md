# Nube: Google Drive (3 cuentas) y OneDrive

Cada cuenta se monta en una carpeta con **su correo como nombre**, y aparece en el panel lateral de **Nemo**. Los correos reales se omiten aquí porque el repo es público: sustitúyelos por los tuyos al seguir la guía.

> Instalado en `~/.local/bin` **sin sudo** porque en este equipo el diálogo de zenity para la contraseña de sudo no responde. `~/.profile` ya añade `~/.local/bin` al `PATH` en sesiones nuevas; en el shell actual usa la ruta absoluta.

## Resumen

| Cuenta | Remote | Carpeta | Servicio (systemd --user) | Estado |
| ------ | ------ | ------- | ------------------------- | ------ |
| Google Drive 1 | `gdrive` | `~/<correo-1>` | `rclone-gdrive.service` | active + enabled |
| Google Drive 2 | `gdrive2` | `~/<correo-2>` | `rclone-gdrive2.service` | active + enabled |
| Google Drive 3 | `gdrive3` | `~/<correo-3>` | `rclone-gdrive3.service` | active + enabled |
| OneDrive | `onedrive` | `~/OneDrive` | `rclone-onedrive.service` | active + enabled |

Todas son carpetas **FUSE montadas bajo demanda** con rclone: los archivos están en la nube y se descargan al abrirlos (no ocupan espacio local). Configuración en `~/.config/rclone/rclone.conf` (permisos `600`, contiene los tokens — **no subir al repo**).

## Google Drive (rclone v1.76.0)

- Binario: `~/.local/bin/rclone`
- Remotes: `gdrive`, `gdrive2`, `gdrive3` → una carpeta por cuenta, con el correo como nombre
- Todos: `type = drive`, `scope = drive`, `team_drive =`

### Verificar

```bash
systemctl --user status rclone-gdrive.service
mount | grep rclone
ls ~/<correo-1>
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

### Añadir otra cuenta

Repite con un remote nuevo (`gdrive4`, `gdrive5`…) y su propia carpeta con el correo:

```bash
~/.local/bin/rclone authorize drive
mkdir -p "$HOME/<correo-nuevo>"
bash scripts/apps/google-drive.sh "$HOME/<correo-nuevo>" gdrive4
```

**Usa «Usar otra cuenta» en el navegador** para no autorizar la misma cuenta dos veces. Después añade el bookmark con el correo codificado (`@` → `%40`).

> **Cómo saber si es cuenta distinta:** Google emite un `refresh_token` nuevo en cada autorización, así que comparar tokens no sirve. Compara los **IDs de archivo**: `rclone lsjson gdrive: --max-depth 1` contra `rclone lsjson gdrive4: --max-depth 1`. Si los IDs coinciden, autorizaste la misma cuenta otra vez. Para saber el correo de un remote, refresca el token con `rclone about <remote>:` y consulta `https://www.googleapis.com/drive/v3/about?fields=user(emailAddress,displayName)` con el `access_token` (espaciando llamadas: la API tiene cuota por minuto).

> ⚠️ rclone avisa de que su `client_id` compartido se retira en 2026. Si deja de conectar, crea un `client_id` propio en Google Cloud y añade `client_id` / `client_secret` al remote ([docs](https://rclone.org/drive/#making-your-own-client-id)).

### Renombrar una carpeta de cuenta

Si cambias el nombre de la carpeta (por ejemplo al correo), hay que parar el servicio, desmontar y actualizar el unit y el bookmark:

```bash
systemctl --user stop rclone-gdrive.service
fusermount -uz "$HOME/Google Drive"
mv "$HOME/Google Drive" "$HOME/<correo>"
sed -i 's|%h/Google Drive|%h/<correo>|g' ~/.config/systemd/user/rclone-gdrive.service
# Bookmark: file:///home/yorbimv/<correo%40dominio>
systemctl --user daemon-reload
systemctl --user start rclone-gdrive.service
```

> Usa `findmnt -T "$HOME/<carpeta>"` para comprobar si está montada: `grep` por texto puede confundir `Google Drive` con `Google Drive 2`.

### Instalación reproducible

```bash
bash scripts/apps/google-drive.sh "$HOME/<correo>" gdrive
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
mount | grep OneDrive
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
drive_id = <ID>
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

Una entrada por carpeta en `~/.config/gtk-3.0/bookmarks`, con `@` codificado como `%40`:

```
file:///<home>/<correo-1>%40gmail.com
file:///<home>/<correo-2>%40-dominio.com.mx
file:///<home>/<correo-3>%40gmail.com
file:///<home>/OneDrive
```

Si una ventana de Nemo abierta **antes del montaje** sigue mostrando la carpeta vacía, ciérrala y vuelve a abrirla (Nemo cachea el listado). Si no aparecen en el panel, reinicia Nemo (`pkill nemo; nemo &`) o recarga Cinnamon (`Ctrl+Alt+Esc`).
