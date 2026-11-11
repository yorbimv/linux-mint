# Preferencias de Cinnamon

Ajustes aplicados en este equipo. Todos se pueden ver y cambiar con `gsettings` o desde `Menú → Preferencias`.

## Aspecto

| Ajuste        | Valor actual                          | Clave de `gsettings`                              |
| ------------- | ------------------------------------- | ------------------------------------------------- |
| Tema          | `Mint-Y-Dark-Aqua`                    | `org.cinnamon.desktop.interface gtk-theme`        |
| Iconos        | `Mint-Y-Sand`                         | `org.cinnamon.desktop.interface icon-theme`       |
| Cursor        | `Bibata-Modern-Classic`               | `org.cinnamon.desktop.interface cursor-theme`     |
| Fuente        | `Ubuntu 10`                           | `org.cinnamon.desktop.interface font-name`        |
| Fondo         | `linuxmint/default_background.jpg`    | `org.cinnamon.desktop.background picture-uri`     |
| Efectos       | activados                             | `org.cinnamon desktop-effects`                    |
| Esquinas      | desactivadas (`expo`/`scale`/`desktop`)| `org.cinnamon hotcorner-layout`                  |

```bash
gsettings set org.cinnamon.desktop.interface gtk-theme   'Mint-Y-Dark-Aqua'
gsettings set org.cinnamon.desktop.interface icon-theme  'Mint-Y-Sand'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Bibata-Modern-Classic'
gsettings set org.cinnamon.desktop.interface font-name   'Ubuntu 10'
```

## Panel

- Un solo panel, **abajo**, con: menú, lanzadores, lista de ventanas, bandeja del sistema y reloj.
- Configuración: `org.cinnamon panels-enabled = ['1:0:bottom']`.
- Para reiniciar Cinnamon después de un cambio: `cinnamon --replace &` (o `Ctrl+Alt+Esc`).

## Trackpad

| Ajuste                    | Valor     |
| ------------------------- | --------- |
| Clic derecho              | 2 dedos (`fingers`) |
| Toque para hacer clic     | activado  |
| Desplazamiento natural    | activado  |
| Scroll con dos dedos      | activado  |
| Desactivar al escribir    | activado  |

```bash
gsettings set org.cinnamon.desktop.peripherals.touchpad click-method 'fingers'
gsettings set org.cinnamon.desktop.peripherals.touchpad tap-to-click true
gsettings set org.cinnamon.desktop.peripherals.touchpad natural-scroll true
gsettings set org.cinnamon.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.cinnamon.desktop.peripherals.touchpad disable-while-typing true
```

## Energía

- **Suspensión desactivada** tanto con corriente (`sleep-inactive-ac-timeout = 0`) como con batería (`sleep-inactive-battery-timeout = 0`), para no cortar sesiones remotas de RustDesk.
- La pantalla se apaga por inactividad según el protector de pantalla, pero el equipo no suspende.
- La batería está al **~29 %** de su capacidad original: sirve para emergencias, no para trabajar desconectado.

```bash
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
```

## Teclado y entrada

- Distribución: `es` + variante `mac` (`[('xkb', 'es+mac')]`).
- `⌘` (Command) actúa como **Ctrl** y `Option` como **AltGr**. Detalle en [06 · Teclado](../06-hardware-macbook/teclado-mac.md).
- Atajos de ventana estilo macOS en [04 · Atajos](../04-productividad/atajos.md).

## Restaurar todo de golpe

El repo guarda un volcado completo en [`dotfiles/cinnamon/dconf-cinnamon.ini`](../dotfiles/cinnamon/dconf-cinnamon.ini):

```bash
# Guardar la configuración actual antes de reemplazarla
dconf dump /org/cinnamon/ > ~/cinnamon-antes.ini

# Cargar la del repo
dconf load /org/cinnamon/ < dotfiles/cinnamon/dconf-cinnamon.ini

# Aplicar sin cerrar sesión
cinnamon --replace &
```

> Cargar el archivo **reemplaza** toda la configuración de Cinnamon, no solo las claves incluidas. El paso `08-cinnamon` de `install.sh` pide confirmación y guarda una copia previa.

## Otras preferencias

- **Nemo:** vista de iconos (`default-folder-viewer = 'icon-view'`), archivos ocultos desactivados (`Ctrl+H` para verlos).
- **Fecha y hora:** `America/Mexico_City`, sincronizada por NTP.
- **Aplicaciones predeterminadas:**

| Tipo        | Aplicación                          |
| ----------- | ----------------------------------- |
| Navegador   | Brave (`brave-browser.desktop`)     |
| Vídeo       | Celluloid (`video/mp4`)             |
| Imágenes    | Xviewer (`image/png`)               |
| Texto       | Xed (`text/plain`)                  |
| PDF         | Xreader (`application/pdf`)         |

```bash
xdg-settings set default-web-browser brave-browser.desktop
xdg-mime default org.x.editor.desktop text/plain
xdg-mime default xreader.desktop application/pdf
```
