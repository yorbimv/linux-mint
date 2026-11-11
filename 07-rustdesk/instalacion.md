# Instalación y uso de RustDesk

## Instalar / actualizar

```bash
sudo bash scripts/apps/rustdesk.sh
```

El script:

1. Consulta la última versión estable en la API de GitHub.
2. Descarga el `.deb` `rustdesk-<versión>-x86_64.deb`.
3. Lo instala con `apt-get install -y ./archivo.deb` (resuelve dependencias).
4. Habilita y arranca `rustdesk.service`.
5. Muestra la versión instalada.

Comprobar:

```bash
rustdesk --version                  # rustdesk 1.5.1
systemctl is-enabled rustdesk.service
systemctl is-active  rustdesk.service
dpkg -l | grep rustdesk
```

> No se añade ningún repositorio apt: cada actualización se hace volviendo a ejecutar el script.

## Servicio

RustDesk corre como servicio del sistema para permitir conexiones **antes** de iniciar sesión (acceso no supervisado):

```bash
sudo systemctl status rustdesk.service
sudo systemctl restart rustdesk.service
sudo journalctl -u rustdesk.service -n 50 --no-pager
```

Si se quiere desactivar el arranque automático:

```bash
sudo systemctl disable --now rustdesk.service
```

## Acceso no supervisado

En la app (o en la bandeja del sistema):

1. `Configuración → Seguridad → Habilitar acceso no supervisado`.
2. Establecer una **contraseña permanente** (distinta de la temporal).
3. Anotar el **ID** del equipo.

Con eso se puede conectar sin que nadie acepte la sesión en este MacBook.

## Conectarse a otro equipo

1. Abrir RustDesk.
2. Escribir el **ID** del equipo remoto.
3. Introducir la contraseña.
4. Elegir modo: control remoto, transferencia de archivos o solo visualización.

**Atajos dentro de la sesión:**

| Atajo             | Acción                          |
| ----------------- | ------------------------------- |
| `Ctrl+Alt+F`      | Pantalla completa               |
| `Ctrl+Alt+M`      | Mostrar/ocultar barra           |
| `Ctrl+Alt+Del`    | Enviar Ctrl+Alt+Supr al remoto  |
| `Ctrl+Alt+Shift+F`| Alternar modo de visualización  |

## Puertos y red

| Puerto | Protocolo | Uso                          |
| ------ | --------- | ---------------------------- |
| 21115 | TCP       | NAT test                     |
| 21116 | TCP/UDP   | Registro y heartbeat         |
| 21117 | TCP       | Relay                        |
| 21118 | TCP       | WebSocket (web client)       |
| 21119 | TCP/UDP   | WebSocket TLS / directo      |

En este equipo solo aparece `21119/udp` en escucha porque el resto lo gestiona el servidor público. En una red con firewall propio, hay que abrir 21115-21119 TCP y 21116/21119 UDP.

## Archivos de configuración

| Ruta                                              | Contenido                              |
| ------------------------------------------------- | -------------------------------------- |
| `~/.config/rustdesk/RustDesk2.toml`               | Ajustes locales (render, códec, idioma)|
| `~/.config/rustdesk/RustDesk_default.toml`        | Valores por defecto                    |
| `~/.config/rustdesk/peers/<id>.toml`              | Ajustes por equipo remoto (códec)      |
| `~/.local/share/logs/RustDesk/rustdesk_rCURRENT.log` | Log de la última sesión             |

> Contienen el ID y credenciales: no se versionan. En el repo solo está `dotfiles/rustdesk/ajustes.toml` con las claves de vídeo.

## Desinstalar

```bash
sudo systemctl disable --now rustdesk.service
sudo apt-get remove --purge -y rustdesk
rm -rf ~/.config/rustdesk ~/.local/share/logs/RustDesk
```
