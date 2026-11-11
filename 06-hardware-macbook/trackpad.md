# Trackpad

> `bcm5974` · driver `libinput` · clic derecho con **dos dedos** · scroll natural

El trackpad del MacBook funciona de fábrica con el módulo `bcm5974`. Solo hubo que ajustar Cinnamon para que el clic derecho sea con dos dedos (como en macOS) y no con la zona inferior derecha.

## Estado actual

```bash
xinput list | grep -i bcm
# ↳ bcm5974  id=8  [slave pointer]
```

| Ajuste                      | Valor     | `gsettings`                          |
| --------------------------- | --------- | ------------------------------------ |
| Clic derecho                | 2 dedos   | `click-method = 'fingers'`           |
| Toque para hacer clic       | sí        | `tap-to-click = true`                |
| Arrastrar con toque         | sí        | `tap-and-drag = true`                |
| Scroll natural              | sí        | `natural-scroll = true`              |
| Scroll con dos dedos        | sí        | `two-finger-scrolling-enabled = true`|
| Desactivar al escribir      | sí        | `disable-while-typing = true`        |
| Scroll por borde            | no        | `edge-scrolling-enabled = false`     |
| Clic de rueda (3 dedos)     | no        | `middle-click-emulation = false`     |
| Velocidad                   | 0.0       | `speed = 0.0`                        |

## Aplicar

```bash
bash scripts/hardware/trackpad.sh
```

O a mano:

```bash
gsettings set org.cinnamon.desktop.peripherals.touchpad click-method 'fingers'
gsettings set org.cinnamon.desktop.peripherals.touchpad tap-to-click true
gsettings set org.cinnamon.desktop.peripherals.touchpad tap-and-drag true
gsettings set org.cinnamon.desktop.peripherals.touchpad natural-scroll true
gsettings set org.cinnamon.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.cinnamon.desktop.peripherals.touchpad disable-while-typing true
gsettings set org.cinnamon.desktop.peripherals.touchpad edge-scrolling-enabled false
gsettings set org.cinnamon.desktop.peripherals.touchpad speed 0.0
```

El cambio es inmediato, no hace falta reiniciar sesión.

## Clic derecho con dos dedos

`click-method = 'fingers'` activa *clickfinger* en libinput:

- **1 dedo** → clic izquierdo.
- **2 dedos** → clic derecho (menú contextual).
- **3 dedos** → clic central (solo si se activa `middle-click-emulation`).

También se puede comprobar a nivel de libinput:

```bash
xinput list-props 8 | grep -i click
# libinput Click Method Enabled (324): 0, 1   ← 0=button areas, 1=clickfinger
```

Si aparece `1, 0`, está en modo "zonas del botón" (clic derecho abajo a la derecha). Con `gsettings` se corrige.

## Ajustes gráficos

`Menú → Preferencias → Ratón y panel táctil`:

- **Panel táctil:** velocidad, clic con toque, scroll natural, clic derecho.
- **Ratón:** velocidad y botón primario (el trackpad usa la misma configuración de botones).

## Problemas

| Síntoma                                  | Solución                                                            |
| ---------------------------------------- | ------------------------------------------------------------------- |
| El clic derecho abre en la esquina       | `gsettings set ... click-method 'fingers'`                          |
| El cursor salta mientras escribes         | Activar `disable-while-typing`                                      |
| El scroll va "al revés"                  | `gsettings set ... natural-scroll false`                            |
| No hay gestos de pellizco                | Cinnamon no trae gestos avanzados; se pueden añadir con `libinput-gestures` |
| El trackpad no responde tras suspender   | `sudo modprobe -r bcm5974 && sudo modprobe bcm5974`, o reiniciar    |
| El puntero se mueve solo                 | Limpiar la superficie; revisar `xinput list-props 8` (accel)        |

## Gestos opcionales (pellizcar, deslizar)

Cinnamon 6 no incluye gestos multi-touch configurables. Si se quieren, se puede instalar `libinput-gestures`:

```bash
sudo apt-get install -y libinput-tools wmctrl
sudo gpasswd -a "$USER" input
# cerrar sesión y volver a entrar
```

Y crear `~/.config/libinput-gestures.conf` con, por ejemplo:

```conf
gesture pinch in      xdotool key ctrl+minus
gesture pinch out     xdotool key ctrl+plus
gesture swipe left    xdotool key alt+Left
gesture swipe right   xdotool key alt+Right
```

Luego: `libinput-gestures-setup start` y `libinput-gestures-setup autostart`.

> No está instalado en este equipo; es una mejora opcional.
