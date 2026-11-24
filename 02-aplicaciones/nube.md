# Nube: Google Drive y OneDrive

Las carpetas `~/Google Drive` y `~/OneDrive` aparecen en el panel lateral de **Nemo** y se sincronizan con la nube.

> Instaladas en `~/.local/bin` **sin sudo** porque en este equipo el diálogo de zenity para la contraseña de sudo no responde. `~/.profile` ya añade `~/.local/bin` al `PATH` en sesiones nuevas; en el shell actual usa la ruta absoluta.

## Google Drive (rclone v1.76.0)

- Binario: `~/.local/bin/rclone`
- Remote: `gdrive` en `~/.config/rclone/rclone.conf` (permisos `600`)
- Punto de montaje: `~/Google Drive`
- Autostart: servicio de usuario `rclone-gdrive.service` (`active` + `enabled`)

### Cómo se monta

```bash
systemctl --user status rclone-gdrive.service
mount | grep 'Google Drive'
ls "$HOME/Google Drive"
```

Es un **montaje FUSE bajo demanda**: los archivos están en la nube y se descargan al abrirlos (no ocupan espacio local). El caché de escrituras está en `~/.cache/rclone`.

### Si hay que repetir la autorización

```bash
~/.local/bin/rclone authorize drive
```

Inicia sesión en el navegador y pega el token en `~/.config/rclone/rclone.conf` con este formato (una sola línea larga para `token`):

```ini
[gdrive]
type = drive
scope = drive
token = {"access_token":"...","refresh_token":"...","token_type":"Bearer","expiry":"..."}
team_drive =
```

Después: `chmod 600 ~/.config/rclone/rclone.conf` y `systemctl --user restart rclone-gdrive.service`.

> ⚠️ rclone avisa de que su `client_id` compartido se retira en 2026. Si un día deja de conectar, hay que crear un `client_id` propio en Google Cloud y añadir `client_id` / `client_secret` a `rclone.conf` (ver [documentación oficial](https://rclone.org/drive/#making-your-own-client-id)).

### Instalación reproducible

```bash
bash scripts/apps/google-drive.sh
```

El script descarga rclone, crea las carpetas, ajusta `~/.profile` y deja el servicio de usuario instalado. **No incluye tokens**: la autorización OAuth es manual y privada.

## OneDrive (cliente onedrive v2.4.25)

- Binario: `~/.local/bin/onedrive` (wrapper) → `~/.local/bin/onedrive-bin`
- Librerías D: `~/.local/lib/libphobos2-ldc-shared.so.106` y `libdruntime-ldc-shared.so.106`
- Config: `~/.config/onedrive/config` y `~/.config/onedrive/refresh_token`
- Punto de sincronización: `~/OneDrive`

> El wrapper exporta `LD_LIBRARY_PATH="$HOME/.local/lib"` porque las librerías D no se pudieron instalar con apt (sudo sin contraseña).

### Estado

La carpeta `~/OneDrive` ya está creada y enlazada en Nemo. La **autorización de Microsoft está pendiente**: al ejecutar el cliente por primera vez muestra una URL de login; tras aceptar los permisos hay que pegar la URL de respuesta (`https://login.microsoftonline.com/common/oauth2/nativeclient?code=...`).

### Sincronización

El cliente `onedrive` **sincroniza** (no monta): los archivos se guardan físicamente en `~/OneDrive`. Para iniciarlo:

```bash
~/.local/bin/onedrive --synchronize
```

Para dejarlo automático con systemd de usuario:

```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/onedrive.service <<'EOF'
[Unit]
Description=Sincronizar OneDrive
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=%h/.local/bin/onedrive --monitor
Restart=on-failure
RestartSec=30

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now onedrive.service
```

## Bookmarks de Nemo

Ambas carpetas están en `~/.config/gtk-3.0/bookmarks`:

```
file:///home/yorbimv/Google%20Drive
file:///home/yorbimv/OneDrive
```

Si no aparecen de inmediato, reinicia Nemo (`pkill nemo; nemo &`) o recarga Cinnamon (`Ctrl+Alt+Esc`).
