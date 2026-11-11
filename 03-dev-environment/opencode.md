# OpenCode

[OpenCode](https://opencode.ai) es el agente de IA que se usa en este equipo. Está instalado como **aplicación de escritorio** (`.deb`), no como CLI.

## Instalación

```bash
# Descargar el .deb más reciente
curl -fsSL -o /tmp/opencode-desktop.deb \
  https://github.com/sst/opencode/releases/latest/download/opencode-desktop-linux-amd64.deb

sudo apt-get install -y /tmp/opencode-desktop.deb
```

Comprobar:

```bash
dpkg -l | grep opencode     # opencode 2.2.7
```

Se abre desde el menú de aplicaciones como **OpenCode**.

## Configuración

Archivo: `~/.config/opencode/opencode.json` (versionado en [`dotfiles/opencode/`](../dotfiles/opencode/)).

```json
{
  "mcp": {
    "servers": {
      "context7": {
        "type": "remote",
        "url": "https://mcp.context7.com/mcp"
      }
    }
  }
}
```

### ¿Qué es MCP?

*Model Context Protocol*: servidores que le dan herramientas y documentación al agente. Aquí hay uno configurado:

| Servidor   | Tipo   | Para qué                                                        |
| ---------- | ------ | --------------------------------------------------------------- |
| `context7` | remoto | Documentación actualizada de librerías y frameworks             |

Se usa solo cuando hace falta consultar documentación; no requiere claves.

### Añadir otro servidor MCP

```json
{
  "mcp": {
    "servers": {
      "context7": {
        "type": "remote",
        "url": "https://mcp.context7.com/mcp"
      },
      "mi-servidor": {
        "type": "local",
        "command": ["npx", "-y", "@modelo/mcp-server"],
        "environment": { "API_KEY": "..." }
      }
    }
  }
}
```

Cierra y vuelve a abrir OpenCode después de editar el archivo.

## Modelos y cuenta

- Los modelos se configuran dentro de la app (`Settings → Models`); no se guardan claves en este repo.
- Se usan modelos en la nube. Este equipo **no** ejecuta modelos locales (ver [05 · IA Local](../05-ia-local/)).
- El historial y la caché viven en `~/.local/share/opencode/` y `~/.cache/opencode/`; no se versionan.

## Uso desde este repo

```bash
cd ~/Documentos/GitHub/linux-mint
opencode        # si tienes el CLI; si no, abre la app de escritorio
```

Ejemplos de tareas que se le pueden pedir:

- "Revisa que los scripts de `scripts/steps/` sean idempotentes."
- "Añade una sección al README para la impresora."
- "Explícame por qué el WiFi no cargó después de actualizar el kernel."

## Actualizar

El `.deb` no tiene repositorio apt; hay que descargar la versión nueva:

```bash
curl -fsSL -o /tmp/opencode-desktop.deb \
  https://github.com/sst/opencode/releases/latest/download/opencode-desktop-linux-amd64.deb
sudo apt-get install -y /tmp/opencode-desktop.deb
```

## Problemas

| Síntoma                        | Solución                                                   |
| ------------------------------ | ---------------------------------------------------------- |
| La app no abre                 | `sudo apt-get install -f` y revisa `~/.local/share/opencode/log/` |
| `context7` no responde         | Comprueba internet y que la URL sea `https://mcp.context7.com/mcp` |
| No aparecen modelos            | Inicia sesión de nuevo en `Settings → Models`               |
