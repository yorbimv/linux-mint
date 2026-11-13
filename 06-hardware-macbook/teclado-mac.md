# Teclado Mac español

> Apple Internal Keyboard / Trackpad · variante propia `es(mac)` · `⌘` = Ctrl · `Option` = AltGr

El teclado del MacBook es un **Apple Spanish ISO**: las teclas físicas no coinciden con la distribución `es` estándar de Linux. La solución fue crear una variante de teclado que copia el mapa de macOS (`com.apple.keylayout.Spanish-ISO`).

## Qué se instaló

| Pieza                                   | Contenido                                                        |
| --------------------------------------- | ---------------------------------------------------------------- |
| `/usr/share/X11/xkb/symbols/es`         | Bloque `xkb_symbols "mac"` añadido al final                        |
| `/usr/share/X11/xkb/rules/evdev.xml`    | Entrada `mac` dentro del layout `es` (para el menú gráfico)       |
| `/usr/share/X11/xkb/rules/evdev.lst`    | Variante `mac` listada                                            |
| `/usr/share/X11/xkb/rules/base.lst`     | Variante `mac` listada                                            |
| `/etc/default/keyboard`                 | `XKBLAYOUT="es"`, `XKBVARIANT="mac"`                              |
| Cinnamon `input-sources`                | `[('xkb', 'es+mac')]`                                             |

Copia de la variante: [`dotfiles/xkb/es-mac-variant.xkb`](../dotfiles/xkb/es-mac-variant.xkb).
Script instalador: [`scripts/hardware/wifi-helper/instalar-teclado-mac.sh`](../scripts/hardware/wifi-helper/instalar-teclado-mac.sh).

## Instalar / reinstalar

```bash
sudo bash scripts/hardware/wifi-helper/instalar-teclado-mac.sh
```

El script es idempotente: si la variante ya existe, no la duplica; solo actualiza las entradas del menú y `/etc/default/keyboard`. Antes de tocar nada crea respaldos `.bak.<fecha>`.

Después, aplicar en la sesión actual:

```bash
setxkbmap -layout es -variant mac -option terminate:ctrl_alt_bksp -option ctrl:swap_lwin_lctl
gsettings set org.cinnamon.desktop.input-sources sources "[('xkb', 'es+mac')]"
```

O cerrar sesión y volver a entrar.

## Cómo funciona

### ⌘ Command = Ctrl

La opción `ctrl:swap_lwin_lctl` intercambia la tecla **Command** (Super izquierda) con **Ctrl izquierdo**. Así `⌘C`, `⌘V`, `⌘Q` funcionan como en macOS.

### Option = AltGr (Level3)

El MacBook **no tiene Alt derecho**. Para poder escribir `@`, `#`, `€`… con `Option`, la variante incluye al final:

```xkb
include "level3(lalt_switch)"
```

Eso hace que **Option izquierdo** sea el modificador de tercer nivel (*Level3*), igual que AltGr en un teclado PC. Por eso `Alt+Tab` deja de funcionar y el cambio de ventana se movió a `⌘Tab` (ver [atajos](../04-productividad/atajos.md)).

### Símbolos Option

| Tecla física | Normal | Shift | Option | Option+Shift |
| ------------ | ------ | ----- | ------ | ------------ |
| `1`          | 1      | !     | `\|`   | `ı`          |
| `2`          | 2      | "     | `@`    | `˝`          |
| `3`          | 3      | ·     | `#`    | `•`          |
| `4`          | 4      | $     | `¢`    | `£`          |
| `5`          | 5      | %     | `∞`    | `‰`          |
| `6`          | 6      | &     | `¬`    | —            |
| `7`          | 7      | /     | `÷`    | `⁄`          |
| `8`          | 8      | (     | `“`    | `‘`          |
| `9`          | 9      | )     | `”`    | `’`          |
| `0`          | 0      | =     | `≠`    | `≈`          |
| `e`          | e      | E     | `€`    | `€`          |
| `+`          | +      | *     | `]`    | `±`          |
| `'`          | '      | ?     | `´`    | `¸`          |

El mapa completo está en el archivo de la variante. Está reconstruido a partir del layout de macOS, así que los símbolos coinciden con las leyendas impresas en las teclas.

> Nota: el trackpad y el teclado comparten el mismo dispositivo USB (`Apple Inc. Apple Internal Keyboard / Trackpad`); no hay que configurar nada extra para que el teclado funcione.

## Verificar

```bash
setxkbmap -query
# layout: es
# variant: mac
# options: terminate:ctrl_alt_bksp,ctrl:swap_lwin_lctl

gsettings get org.cinnamon.desktop.input-sources sources
# [('xkb', 'es+mac')]

grep -E '^XKB' /etc/default/keyboard
```

Prueba rápida en una terminal o editor:

| Combinación | Debe escribir |
| ----------- | ------------- |
| `⌥2`        | `@`           |
| `⌥3`        | `#`           |
| `⌥e`        | `€`           |
| `⌘C`        | copiar        |
| `⌘Q`        | cerrar ventana|

## Toque de ⌘ para abrir el menú

El intercambio `ctrl:swap_lwin_lctl` deja `Super_L` en la **tecla física Ctrl**, y Cinnamon solo abre el menú con `Super`. Para que un **toque de ⌘** abra el menú sin perder `⌘C`/`⌘V`, se usa **xcape** con la tecla `Menu`:

```bash
sudo apt-get install -y xcape
xcape -e 'Control_L=Menu'
```

- **Toque de ⌘** → envía `Menu` → abre/cierra el menú.
- **Mantener ⌘** + otra tecla → sigue siendo `Ctrl` → atajos de siempre.
- **Ctrl físico solo** (`Super_L`) → círculo de **localizar el puntero**, sin abrir el menú.

La tecla del menú del applet se configura en `Menu` (ni `Control_L` ni `Super_R` funcionan para eso). Además se ajusta `locate-pointer-key` a `Super_L` para que el círculo siga respondiendo a Ctrl:

```bash
gsettings set org.cinnamon.muffin locate-pointer-key "['Super_L']"
gsettings set org.cinnamon.desktop.peripherals.mouse locate-pointer true
```

Se instala con [`dotfiles/cinnamon/atajos-mac.sh`](../dotfiles/cinnamon/atajos-mac.sh) (paso `08-cinnamon`), que también crea el autostart de la sesión.

## Mover ventanas y cambiar de escritorio

El intercambio deja dos teclas con funciones distintas:

| Tecla física | Emite      | Para qué se usa                                  |
| ------------ | ---------- | ------------------------------------------------ |
| **⌘**        | `Control_L` | Mover/azulear ventanas (`⌘+flechas`), copiar, etc. |
| **Ctrl**     | `Super_L`   | Cambiar de escritorio (`Ctrl+flechas`) y localizar el puntero |

Por eso los atajos de ventana usan solo `<Control>` y los de escritorio solo `<Super>`:

```bash
WM=org.cinnamon.desktop.keybindings.wm
gsettings set $WM push-tile-left  "['<Control>Left']"    # ⌘+←
gsettings set $WM push-tile-right "['<Control>Right']"   # ⌘+→
gsettings set $WM push-tile-up    "['<Control>Up']"      # ⌘+↑
gsettings set $WM push-tile-down  "['<Control>Down']"    # ⌘+↓
gsettings set $WM switch-to-workspace-left  "['<Super>Left']"   # Ctrl+←
gsettings set $WM switch-to-workspace-right "['<Super>Right']"  # Ctrl+→
gsettings set $WM move-to-workspace-left    "['<Super><Shift>Left']"   # Ctrl+Shift+←
gsettings set $WM move-to-workspace-right   "['<Super><Shift>Right']"  # Ctrl+Shift+→
gsettings set $WM move-to-monitor-left      "['<Control><Super>Left']"  # ⌘+Ctrl+←
gsettings set $WM move-to-monitor-right     "['<Control><Super>Right']" # ⌘+Ctrl+→
```

Así **Ctrl deja de mover ventanas**: si antes `Ctrl+←` azuleaba la ventana, ahora cambia de escritorio y deja Ctrl libre para “localizar el puntero”.

Para **pasar una ventana al otro escritorio**: `Ctrl+Shift+←` o `Ctrl+Shift+→`.

> La combinación antigua `⌘+Shift+Option+flechas` no funciona en el teclado del MacBook: Option emite `ISO_Level3_Shift`, pero Cinnamon esperaba `Alt` (`Mod1`). Por eso se usa `Ctrl+Shift+flechas`, que sí está disponible.

## Se perdió después de actualizar

Las actualizaciones de **`xkb-data`** reescriben `/usr/share/X11/xkb/symbols/es` y borran el bloque `mac`. Solución:

```bash
sudo bash scripts/hardware/wifi-helper/instalar-teclado-mac.sh
setxkbmap -layout es -variant mac -option terminate:ctrl_alt_bksp -option ctrl:swap_lwin_lctl
```

Si el menú gráfico ya no muestra la variante, el script también la vuelve a registrar. Es el primer paso de la lista de verificación tras un `apt upgrade` grande.

## Volver al teclado estándar

```bash
setxkbmap -layout es
gsettings set org.cinnamon.desktop.input-sources sources "[('xkb', 'es')]"
```

Y editar `/etc/default/keyboard` para quitar `XKBVARIANT="mac"` (hay respaldos `.bak.*`).

## Problemas

| Síntoma                                   | Solución                                                          |
| ----------------------------------------- | ----------------------------------------------------------------- |
| `⌥2` escribe `"` en vez de `@`            | La variante no está activa: `setxkbmap -query` y reinstalar        |
| `⌘` no copia/pega                         | Falta `ctrl:swap_lwin_lctl` en las opciones                        |
| El menú no se abre con un toque de `⌘`    | xcape no corre o usa el mapeo viejo: `pkill -x xcape; setsid -f xcape -e 'Control_L=Menu'` |
| Ctrl no muestra el círculo del puntero    | `gsettings set org.cinnamon.muffin locate-pointer-key "['Super_L']"` y `gsettings set org.cinnamon.desktop.peripherals.mouse locate-pointer true` |
| `Alt+Tab` no cambia de ventana            | Es normal: usar `⌘Tab`                                            |
| Ctrl mueve la ventana en vez de cambiar de escritorio | Reaplicar: `bash dotfiles/cinnamon/atajos-mac.sh` (los atajos de ventana llevan `<Super>` de más) |
| Ctrl+flechas no cambia de escritorio      | `gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-right "['<Super>Right']"` |
| Acentos raros o teclas muertas            | Revisar que la variante sea `es(mac)`, no `es` a secas             |
| Tras actualizar, todo vuelve al layout PC | `xkb-data` borró el bloque: reinstalar la variante                |
| El menú de Cinnamon no lista "Macintosh"  | Faltan las entradas en `evdev.xml`/`evdev.lst`: reinstalar         |

## Desinstalar

```bash
sudo cp -a /usr/share/X11/xkb/symbols/es.bak.* /usr/share/X11/xkb/symbols/es 2>/dev/null
sudo cp -a /usr/share/X11/xkb/rules/evdev.xml.bak.* /usr/share/X11/xkb/rules/evdev.xml 2>/dev/null
sudo cp -a /etc/default/keyboard.bak.* /etc/default/keyboard 2>/dev/null
setxkbmap -layout es
```

(Los respaldos son los que crea el instalador con la fecha de instalación.)
