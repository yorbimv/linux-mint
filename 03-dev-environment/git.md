# Git y GitHub

## Instalación

```bash
sudo apt-get install -y git gh
git --version      # 2.43.0
gh --version       # 2.45.0
```

## Identidad

Git necesita nombre y correo para firmar los commits. Se configuran una sola vez:

```bash
git config --global user.name  "Jorge Meneses"
git config --global user.email "yorbimv@users.noreply.github.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor "xed --wait"
```

Comprobar:

```bash
git config --global --list
```

> El correo `@users.noreply.github.com` evita publicar tu correo real en los commits. Si prefieres el tuyo, cámbialo.

## Autenticación con GitHub

### Opción A — GitHub CLI (recomendada)

```bash
gh auth login
```

Responde:

1. **GitHub.com**
2. **SSH** (o HTTPS)
3. **Login with a web browser** → copia el código de un solo uso y pégalo en el navegador.

Comprobar:

```bash
gh auth status
gh repo list --limit 5
```

### Opción B — Clave SSH manual

```bash
ssh-keygen -t ed25519 -C "yorbimv@users.noreply.github.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Pega la clave pública en `GitHub → Settings → SSH and GPG keys → New SSH key`, y prueba:

```bash
ssh -T git@github.com
```

## Clonar este repo

```bash
git clone https://github.com/yorbimv/linux-mint.git ~/Documentos/GitHub/linux-mint
cd ~/Documentos/GitHub/linux-mint
```

Con SSH:

```bash
git clone git@github.com:yorbimv/linux-mint.git ~/Documentos/GitHub/linux-mint
```

## Flujo de trabajo

```bash
cd ~/Documentos/GitHub/linux-mint

./scripts/guardar.sh              # captura la configuración actual
git status --short                # revisar qué cambió
git diff                          # ver el detalle

git add -A
git commit -m "config: teclado y atajos"
git push
```

- Un commit por cambio lógico; mensajes en presente (`config: ...`, `docs: ...`, `fix: ...`).
- Antes de hacer `push`, `git pull --rebase` si el repo se editó desde otro equipo.
- `./install.sh` marca los pasos hechos en `~/.cache/linux-mint-bootstrap-done`; ese archivo **no** se versiona.

## Repos de referencia

| Repo                              | Qué contiene                     |
| --------------------------------- | -------------------------------- |
| `yorbimv/linux-mint`              | Este equipo (Linux Mint)         |
| `yorbimv/macos`                   | Configuración del Mac            |

## Problemas típicos

| Síntoma                                     | Solución                                                        |
| ------------------------------------------- | --------------------------------------------------------------- |
| `Permission denied (publickey)`             | `ssh-add ~/.ssh/id_ed25519` y verifica la clave en GitHub       |
| `Author identity unknown`                   | Falta `user.name` / `user.email` (ver arriba)                    |
| `gh: not logged in`                         | `gh auth login`                                                  |
| `src refspec main does not match any`       | Aún no hay commits: `git add -A && git commit -m "inicio"`       |
| El push pide usuario y contraseña           | Usa un **token** como contraseña o cambia a SSH (`gh auth setup-git`) |
