# LED rojo del jack de audífonos

> El LED rojo dentro del jack de 3.5 mm **no es una falla** ni un indicador de grabación. Es el **emisor óptico S/PDIF** del conector combinado del MacBook Pro A1278.

## Qué es

El jack de audífonos del Mac es un **combo analógico + óptico (mini-TOSLINK)**. Además de la salida normal de audífonos, tiene un transmisor láser para audio digital. Ese láser es la luz roja.

En este equipo el códec es un **Cirrus Logic CS4206** y el conector está repartido en dos nodos:

| Nodo   | Función                        | Estado normal |
| ------ | ------------------------------ | ------------- |
| `0x09` | Audífonos analógicos (HP Out)  | apagado si no hay audífonos |
| `0x10` | Salida óptica S/PDIF           | **se queda encendida** |

El nodo `0x10` se alimenta del convertidor digital `0x08`. Si el códec lo deja en `D0` y el pin en `OUT`, el LED permanece encendido aunque no haya ningún cable conectado.

## Por qué pasa

- El driver `snd-hda-intel` deja el convertidor S/PDIF alimentado por defecto.
- PipeWire/WirePlumber vuelve a activar los interruptores `IEC958` al iniciar sesión.
- No tiene relación con polvo ni con el jack sucio: es un ajuste del chip de audio.
- En macOS lo controla el **SMC**; si se queda pegado, se resuelve reseteando el SMC.

## Solución permanente

```bash
sudo bash scripts/hardware/apagar-led-optico.sh --instalar
```

O con el instalador:

```bash
./install.sh 12
```

El script hace tres cosas:

1. Apaga los interruptores digitales `IEC958` con `amixer`.
2. Pone el convertidor digital (`0x08`) en `D3` y deshabilita el pin `0x10` con `hda-verb`.
3. Instala el apagado automático:
   - servicio `macbook-led-optico.service` al arrancar;
   - entrada de autostart al iniciar sesión (después de PipeWire);
   - hook `systemd-sleep` al volver de suspensión.

### Aplicar solo una vez (se pierde al reiniciar)

```bash
sudo bash scripts/hardware/apagar-led-optico.sh
```

## Verificar

```bash
# El convertidor debe estar en D3 y sin stream
awk '/^Node 0x08 /{p=1} p{print} p&&/^$/{exit}' /proc/asound/card0/codec#0 \
  | grep -E 'Converter|Digital:|Power:'

# El pin óptico debe estar deshabilitado (0x00)
awk '/^Node 0x10 /{p=1} p{print} p&&/^$/{exit}' /proc/asound/card0/codec#0 \
  | grep 'Pin-ctls'
```

Debe verse `Power: setting=D3, actual=D3` y `Pin-ctls: 0x00`.

## Si el LED sigue encendido

- Comprueba que `hda-verb` esté instalado: `command -v hda-verb` (paquete `alsa-tools`).
- Ejecuta el script y revisa que el nodo `0x08` baje a `D3`.
- Si el códec vuelve a `D0` solo, en macOS el último recurso es **resetear el SMC**; en Linux se puede repetir el script tras cada inicio de sesión.
