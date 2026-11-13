# Atajos de teclado estilo macOS

La tecla **⌘ (Command)** del MacBook se reasignó a **Ctrl**, y **Option** a **AltGr**. A partir de ahí, Cinnamon usa atajos idénticos a macOS para las ventanas.

> Script: [`dotfiles/cinnamon/atajos-mac.sh`](../dotfiles/cinnamon/atajos-mac.sh) · Paso: `08-cinnamon`

## Atajos de ventana

| Atajo            | Acción                                   | Clave de Cinnamon        |
| ---------------- | ---------------------------------------- | ------------------------ |
| `⌘Q`             | Cerrar la ventana activa                 | `close`                  |
| `⌘M` / `⌘H`      | Minimizar / ocultar                      | `minimize`               |
| `⌘⇧M`            | Maximizar / restaurar                    | `toggle-maximized`       |
| `⌘Tab`           | Cambiar de ventana                       | `switch-windows`         |
| `⌘⇧Tab`          | Cambiar de ventana hacia atrás            | `switch-windows-backward`|
| `⌘←` / `⌘→`      | Ventana a la mitad izquierda / derecha    | `push-tile-left/right`   |

Se aplican con:

```bash
./dotfiles/cinnamon/atajos-mac.sh              # aplicar
./dotfiles/cinnamon/atajos-mac.sh --revertir   # volver a los de Cinnamon
```

Ver los valores actuales:

```bash
gsettings get org.cinnamon.desktop.keybindings.wm close
gsettings get org.cinnamon.desktop.keybindings.wm toggle-maximized
```

También se pueden editar gráficamente en `Menú → Preferencias → Teclado → Atajos → Ventanas`.

## ¿Por qué `⌘Tab` y no `Alt+Tab`?

Al hacer que **Option** funcione como **AltGr** (para escribir `@`, `#`, `€`… como en macOS), `Alt+Tab` deja de ser cómodo: Option izquierdo ya no es un Alt normal. Por eso el cambio de ventana se movió a `⌘Tab` (`Ctrl+Tab`) y `Super+Tab`.

## Atajos de edición (estándar)

| Atajo        | Acción                    |
| ------------ | ------------------------- |
| `⌘C` / `⌘V`  | Copiar / pegar            |
| `⌘X`         | Cortar                    |
| `⌘Z`         | Deshacer                  |
| `⌘⇧Z`        | Rehacer                   |
| `⌘A`         | Seleccionar todo          |
| `⌘F`         | Buscar                    |
| `⌘S`         | Guardar                   |
| `⌘P`         | Imprimir                  |
| `⌘N`         | Nueva ventana/documento   |
| `⌘W`         | Cerrar pestaña            |
| `⌘,`         | Preferencias              |

> En macOS `⌘Q` cierra la **aplicación**; en Cinnamon cierra la **ventana**. Si tienes varias ventanas abiertas, se cierran una por una.

## Terminal

| Atajo             | Acción                          |
| ----------------- | ------------------------------- |
| `⌘C`              | Interrumpir el comando          |
| `⌘D`              | Cerrar la terminal              |
| `⌘L`              | Limpiar la pantalla             |
| `⌘K`              | Limpiar el historial visible    |
| `⌘+` / `⌘-`       | Aumentar / reducir fuente       |
| `⌘⇧C` / `⌘⇧V`     | Copiar / pegar en la terminal   |
| `Ctrl+R`          | Buscar en el historial          |

## Escritorio y sistema

| Atajo             | Acción                             |
| ----------------- | ---------------------------------- |
| `Toque ⌘`         | Abrir / cerrar el menú (xcape)     |
| `Ctrl` (solo)     | Localizar el puntero (círculo)     |
| `Super+E`         | Abrir el gestor de archivos (Nemo) |
| `Super+L`         | Bloquear la sesión                 |
| `Super+D`         | Mostrar el escritorio              |
| `Ctrl+Alt+Esc`    | Reiniciar Cinnamon                 |
| `Ctrl+Alt+Supr`   | Cerrar sesión / apagar             |
| `Impr Pant`       | Captura de pantalla                |

## Un toque de ⌘ abre el menú (xcape)

El intercambio `ctrl:swap_lwin_lctl` hace que:

- la tecla física **⌘** emita `Control_L`;
- la tecla física **Ctrl** emita `Super_L`.

Cinnamon solo acepta `Super` como tecla del menú, así que sin ayuda el menú se abriría con la tecla física **Ctrl**, no con ⌘. La solución usa la tecla **Menu** y **xcape**:

```bash
sudo apt-get install -y xcape
xcape -e 'Control_L=Menu'
gsettings set org.cinnamon.muffin locate-pointer-key "['Super_L']"
gsettings set org.cinnamon.desktop.peripherals.mouse locate-pointer true
```

- **Toque de ⌘** → envía `Menu` → abre/cierra el menú.
- **Mantener ⌘** + otra tecla → sigue siendo `Ctrl` → `⌘C`, `⌘V`, `⌘Q` funcionan igual.
- **Ctrl físico solo** → `Super_L` → muestra el círculo de **localizar el puntero** y **no** abre el menú.

`atajos-mac.sh` también pone la tecla del menú del applet en `Menu`, porque `Control_L` y `Super_R` no funcionan como atajo del menú. Instala xcape y crea el autostart `~/.config/autostart/xcape-cmd-menu.desktop` para que arranque con la sesión. Para desactivarlo:

```bash
./dotfiles/cinnamon/atajos-mac.sh --revertir
```

## Símbolos con Option (AltGr)

| Combinación | Símbolo | Combinación | Símbolo |
| ----------- | ------- | ----------- | ------- |
| `⌥1`        | `\|`    | `⌥2`        | `@`     |
| `⌥3`        | `#`     | `⌥4`        | `¢`     |
| `⌥5`        | `∞`     | `⌥e`        | `€`     |
| `⌥'`        | `´`     | `⌥+`        | `±`     |

El resto del mapa está en [`dotfiles/xkb/es-mac-variant.xkb`](../dotfiles/xkb/es-mac-variant.xkb) y se explica en [06 · Teclado](../06-hardware-macbook/teclado-mac.md).

## Si algo no responde

1. Comprueba que el teclado está en `es+mac`:

   ```bash
   setxkbmap -query
   gsettings get org.cinnamon.desktop.input-sources sources
   ```

2. Reaplica los atajos:

   ```bash
   ./dotfiles/cinnamon/atajos-mac.sh
   ```

3. Reinicia Cinnamon: `cinnamon --replace &`.
