# 07 · RustDesk

> Cliente 1.5.1 desde el `.deb` oficial · servicio `rustdesk.service` activo · servidores públicos de RustDesk

RustDesk se usa para **entrar a este MacBook desde otro equipo** y para **conectarse al Mac de la oficina**. No viene de un repositorio apt: se instala desde GitHub para tener siempre la última versión.

> **Estado: funcionando** (noviembre 2026). Con `codec-preference = 'vp8'` y `use-texture-render = 'N'` la sesión recibe vídeo y audio a 30 fps. La causa del "esperando imagen" era el equipo remoto (dormido/bloqueado o sin permisos de grabación de pantalla).

## Contenido

- [Instalación y uso](instalacion.md) — `.deb`, servicio, acceso no supervisado y actualización.
- [Problemas y "esperando imagen"](problemas.md) — diagnóstico de vídeo/audio y qué revisar en el equipo remoto.

## Resumen rápido

```bash
# Instalar o actualizar
sudo bash scripts/apps/rustdesk.sh

# Estado del servicio
systemctl is-active rustdesk.service

# Ajustes de vídeo para la GPU Intel
bash dotfiles/rustdesk/video.sh

# Diagnóstico de la última sesión
bash dotfiles/rustdesk/estado.sh
```

## Configuración de este equipo

| Ajuste                    | Valor                        | Dónde                          |
| ------------------------- | ---------------------------- | ------------------------------ |
| Servicio                  | `enabled` + `active`         | `rustdesk.service`             |
| Servidor rendezvous       | público (`rs-*.rustdesk.com`)| configuración de RustDesk      |
| Códec preferido           | VP8                          | `peers/<id>.toml`              |
| Render de vídeo           | CPU (`use-texture-render = N`)| `RustDesk2.toml`              |
| Acceso no supervisado     | activado con contraseña fija | app → Seguridad                |
| Puerto de escucha         | UDP 21119                    | `ss -lunp`                     |

> Los archivos de RustDesk pueden contener el ID y la contraseña del equipo. **No** se versionan en el repo; solo se guardan los ajustes de vídeo en [`dotfiles/rustdesk/`](../dotfiles/rustdesk/).

## Requisitos para que funcione bien

- Este equipo debe estar **encendido y despierto**. La suspensión está desactivada en [preferencias](../01-sistema/preferencias.md).
- El equipo remoto debe tener RustDesk **abierto, desbloqueado y con los permisos de accesibilidad/grabación de pantalla** concedidos (en macOS: *Privacidad y seguridad → Grabación de pantalla* y *Accesibilidad*).
- Ambos lados con la **misma versión** (1.5.1 o superior).
- Red sin bloqueo de UDP 21116/21119; si falla, RustDesk usa relay TCP 443.

## Por qué hay ajustes de vídeo

La GPU Intel HD 4000 de este MacBook no lleva bien el render por textura ni la decodificación HEVC por software. Con los valores por defecto, la sesión podía quedarse en **"esperando imagen"**. Los ajustes de [`video.sh`](../dotfiles/rustdesk/video.sh) fuerzan:

1. **VP8** en vez de H.265 (mucho más ligero de decodificar).
2. **Render por CPU** en vez de textura GPU.

Son reversibles: `bash dotfiles/rustdesk/video.sh --revertir`.

## Nota sobre el servidor público

Desde 2025 el servidor público de RustDesk **exige iniciar sesión** (Google/GitHub) para conectar. Si aparece:

```
The connection is not allowed. The public server currently requires users to log in
```

hay que abrir RustDesk → `Iniciar sesión` y autenticarse. Con servidor propio (self-hosted) esto no aplica.

## Siguiente paso

[Solución de problemas](../troubleshooting/) → índice de fallos comunes y su arreglo.
