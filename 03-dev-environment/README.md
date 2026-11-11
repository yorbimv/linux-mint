# 03 · Dev Environment

Este equipo es **ligero a propósito**: Intel i5 de 2012 con 15 GB de RAM. El entorno de desarrollo es mínimo y funciona bien: Bash, Git, GitHub CLI, Python y OpenCode. No hay Node, Docker, zsh ni neovim instalados.

## Herramientas instaladas

| Herramienta       | Versión        | Para qué                                  |
| ----------------- | -------------- | ----------------------------------------- |
| Bash              | 5.2            | Shell por defecto                          |
| Git               | 2.43.0         | Control de versiones                       |
| GitHub CLI (`gh`) | 2.45.0         | Repos, PRs, autenticación                  |
| Python            | 3.12.3         | Scripts y utilidades                       |
| build-essential   | —              | `gcc`, `make`, headers (DKMS del WiFi)     |
| OpenCode Desktop  | 2.2.7          | Agente de IA con MCP                       |
| Xed               | —              | Editor de texto gráfico                    |

Instalación base (paso `02-apt`):

```bash
sudo apt-get install -y git gh curl wget build-essential dkms dconf-cli python3
```

## Contenido

- [Bash](bash.md) — `.bashrc`, alias y `PATH`.
- [Git y GitHub](git.md) — identidad, `gh auth login`, claves SSH y flujo de trabajo.
- [OpenCode](opencode.md) — instalación, configuración y MCP.

## Lo que no está instalado (y por qué)

| Herramienta | Motivo                                                        |
| ----------- | ------------------------------------------------------------- |
| Node.js     | No se desarrolla frontend en este equipo                      |
| Docker      | El hardware va justo de CPU; se usan contenedores en remoto    |
| zsh / oh-my-zsh | Bash es suficiente y arranca más rápido                   |
| neovim / VS Code | Se usa Xed para edits rápidos y OpenCode para el resto    |

Si algún día se necesitan:

```bash
# Node LTS desde NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# VS Code desde el repo de Microsoft
sudo apt-get install -y code
```

## Siguiente paso

[04 · Productividad](../04-productividad/) → atajos de teclado y apps del día a día.
