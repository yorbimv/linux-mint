# Problemas de RustDesk

## "Esperando imagen" / pantalla negra

Es el fallo que más tiempo costó. La sesión conecta, se ve el cursor o el fondo, pero el vídeo nunca llega.

### 1. Causa más probable: el equipo remoto

En la mayoría de los casos **no es este MacBook**, sino el equipo al que te conectas:

- Está **bloqueado, suspendido o con la pantalla apagada**. RustDesk no puede capturar nada.
- macOS no le dio permiso de **Grabación de pantalla** (`Privacidad y seguridad → Grabación de pantalla`) o de **Accesibilidad**.
- Tiene activado un **modo de privacidad** o un protector que oculta la pantalla.
- Versión de RustDesk distinta o anterior a 1.5.1.

Checklist en el equipo remoto:

1. Dejarlo desbloqueado y despierto (`caffeinate -d` en macOS evita que se duerma).
2. Revisar permisos y **reiniciar RustDesk** después de concederlos.
3. Actualizar a la misma versión.
4. Desactivar modo privacidad / ahorro de energía agresivo.

### 2. Códec

El Mac remoto puede codificar en **H.265/HEVC** y este MacBook decodificarlo por software con muy poca CPU disponible. Se fuerza **VP8**:

```bash
bash dotfiles/rustdesk/video.sh
```

Eso escribe `codec-preference = 'vp8'` en el `.toml` del equipo remoto (`~/.config/rustdesk/peers/<id>.toml`).

### 3. Render por GPU

La Intel HD 4000 falla al dibujar la textura del vídeo. Se fuerza render por CPU:

```bash
bash dotfiles/rustdesk/video.sh
# deja use-texture-render = 'N' en RustDesk2.toml
```

Reiniciar RustDesk después:

```bash
systemctl --user restart rustdesk 2>/dev/null || sudo systemctl restart rustdesk.service
```

### 4. Verificar el log

```bash
bash dotfiles/rustdesk/estado.sh
```

O directamente:

```bash
grep -aE "new video handler|decoder|recved audio|frame|error|failed|connection is not allowed" \
  ~/.local/share/logs/RustDesk/rustdesk_rCURRENT.log | tail -40
```

| Lo que ves en el log                     | Significado                                              |
| ---------------------------------------- | -------------------------------------------------------- |
| `new video handler` y luego nada          | Llegó el canal de vídeo, pero no los frames → códec/render |
| `decoder failed` / `decode error`         | Códec no soportado o GPU; forzar VP8                     |
| `recved audio format` ausente             | El remoto no envía audio o está silenciado               |
| `connection is not allowed`               | Servidor público exige login                             |
| `relay requested`                         | Conexión directa falló; va por relay (más lenta)         |
| Nada después de `Connect`                 | El remoto no acepta o está dormido                       |

## "The connection is not allowed"

```
The connection is not allowed. The public server currently requires users to log in
```

El servidor público de RustDesk exige una cuenta desde 2025. Solución:

1. Abrir RustDesk → **Iniciar sesión** (Google o GitHub).
2. Volver a conectar.
3. Alternativa: montar un servidor RustDesk propio (self-hosted) y configurar `ID/Relay Server`.

## No conecta a ningún equipo

| Comprobación                        | Comando / acción                                   |
| ----------------------------------- | -------------------------------------------------- |
| ¿Servicio activo?                   | `systemctl is-active rustdesk.service`             |
| ¿Hay internet?                      | `ping -c2 1.1.1.1`                                 |
| ¿UDP 21116/21119 sale?              | `ss -lunp \| grep rustdesk`                        |
| ¿Firewall del router?               | Probar desde otra red (datos móviles)              |
| ¿ID correcto?                       | Copiarlo desde la app, no a mano                   |
| ¿Contraseña correcta?               | La permanente, no la temporal                      |
| ¿Misma versión?                     | `rustdesk --version` en ambos lados                |

## Audio no funciona

- En la sesión, activar el icono de altavoz de la barra de RustDesk.
- En Linux, revisar `pavucontrol`: la app remota debe salir por la salida correcta.
- En macOS remoto, RustDesk necesita permiso de micrófono solo para hablar; el audio de salida no requiere permiso.
- Si el remoto está en silencio, el audio tampoco se envía.

## La sesión se corta sola

- **Suspensión del equipo local o remoto.** En este equipo ya está desactivada; en el remoto usar `caffeinate` (macOS) o desactivar el suspensión.
- **WiFi inestable.** Revisar señal; el BCM4331 no es un campeón en 2.4 GHz.
- **Relay saturado.** Si el log dice `relay requested`, la conexión directa falló; abrir los puertos o usar otro servidor.
- **Pantalla bloqueada** en el remoto: RustDesk pierde el vídeo al bloquearse.

## La ventana se ve borrosa o con colores raros

```bash
bash dotfiles/rustdesk/video.sh          # VP8 + render CPU
bash dotfiles/rustdesk/video.sh --revertir   # volver a los valores por defecto
```

Si con VP8 va peor, probar `codec-preference = 'h264'` editando el `.toml` del peer.

## Reiniciar todo

```bash
sudo systemctl restart rustdesk.service
pkill -f rustdesk; sleep 2; rustdesk &
```

Y en el remoto: cerrar RustDesk por completo (incluida la bandeja) y volver a abrirlo.

## Recopilar información para pedir ayuda

```bash
bash dotfiles/rustdesk/estado.sh > /tmp/rustdesk-estado.txt
uname -a >> /tmp/rustdesk-estado.txt
rustdesk --version >> /tmp/rustdesk-estado.txt
```

> Revisa el archivo antes de compartirlo: el log puede contener IDs de equipo.
