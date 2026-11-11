# 05 · IA Local

> En este equipo **no** corre ningún modelo de lenguaje local. La IA se usa a través de OpenCode con modelos en la nube.

## Qué hay instalado

| Herramienta       | Estado     | Función                                  |
| ----------------- | ---------- | ---------------------------------------- |
| OpenCode Desktop  | 2.2.7      | Agente de IA con acceso a archivos y MCP |
| MCP `context7`    | configurado| Documentación actualizada de librerías   |
| Ollama / llama.cpp| no instalado | —                                      |

## Por qué no hay un modelo local

| Factor       | Situación en este MacBook                          |
| ------------ | -------------------------------------------------- |
| CPU          | Intel i5-3210M (2 núcleos / 4 hilos, 2012)         |
| GPU          | Intel HD 4000, sin soporte útil para LLMs           |
| RAM          | 15 GB (suficiente para modelos de 3B, justa para más)|
| Disco        | SSD, pero sin espacio reservado para modelos         |

Un modelo de 7B en CPU rendiría a pocos tokens por segundo y calentaría el equipo. Para este hardware es más práctico usar modelos en la nube.

## Contenido

- [OpenCode y MCP](opencode.md) — cómo está configurado y cómo añadir servidores.
- [Modelos locales (opcional)](modelos-locales.md) — qué se podría correr si hiciera falta.

## Privacidad

- El repo **no** guarda claves de API ni tokens: viven en la configuración local de OpenCode.
- Los archivos que el agente lee se envían al proveedor del modelo solo durante la conversación.
- Para trabajo sensible: usar un modelo local (ver [modelos-locales.md](modelos-locales.md)) o desactivar el envío de contexto.

## Siguiente paso

[06 · Hardware MacBook](../06-hardware-macbook/) → WiFi, teclado y trackpad.
