# OpenCode y MCP

OpenCode es el agente que se usa en este equipo. La configuración completa está en [`dotfiles/opencode/opencode.json`](../dotfiles/opencode/opencode.json) y se instala en el paso `04-dotfiles`.

## Configuración actual

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

| Servidor   | Tipo   | Uso                                                     |
| ---------- | ------ | ------------------------------------------------------- |
| `context7` | remoto | Consultar documentación actualizada de librerías        |

No hay claves ni tokens en el archivo. Los modelos y la autenticación se configuran dentro de la app.

## Instalar / actualizar

```bash
curl -fsSL -o /tmp/opencode-desktop.deb \
  https://github.com/sst/opencode/releases/latest/download/opencode-desktop-linux-amd64.deb
sudo apt-get install -y /tmp/opencode-desktop.deb
```

Más detalle en [03 · OpenCode](../03-dev-environment/opencode.md).

## Añadir un servidor MCP

### Remoto (HTTP)

```json
"mi-api": {
  "type": "remote",
  "url": "https://mcp.ejemplo.com/mcp"
}
```

### Local (proceso)

```json
"archivos": {
  "type": "local",
  "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/home/yorbimv/Documentos"],
  "environment": {}
}
```

Los servidores locales necesitan el comando instalado (`npx`, `uvx`, binario…). Reinicia OpenCode después de editar.

## Herramientas que aporta cada servidor

| Servidor   | Ejemplos de herramientas                                  |
| ---------- | --------------------------------------------------------- |
| `context7` | `resolve-library-id`, `query-docs`                        |

Con `context7` el agente puede consultar la documentación vigente de una librería antes de escribir código, en vez de inventar APIs.

## Buenas prácticas

- Un servidor MCP por tarea; no cargues diez si no se usan.
- Revisa qué herramientas expone un servidor local antes de darlo de alta.
- No pongas secretos en `opencode.json` si el archivo está en un repo público: usa variables de entorno.
- El historial de conversaciones se guarda en `~/.local/share/opencode/`; bórralo si el equipo se comparte.
