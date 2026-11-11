# Navegadores

## Brave (principal)

- Instalado desde el repositorio oficial; se actualiza con `apt`.
- Es el **navegador predeterminado** del sistema.
- Perfil sincronizado con la cuenta de Brave (marcadores, extensiones, contraseñas si se activa el sync).

```bash
brave-browser --version            # Brave Browser 1.99.55
xdg-settings get default-web-browser
```

### Ajustes recomendados

| Ajuste                         | Valor                                      |
| ------------------------------ | ------------------------------------------ |
| Motor de búsqueda              | Google o Brave Search, según preferencia   |
| Bloqueo de anuncios            | Aggressive (Brave Shields)                 |
| Pestañas                       | Barra vertical opcional                    |
| Arranque                       | Continuar donde lo dejaste                 |
| Descargas                      | `~/Descargas`                              |

### Extensiones

Se reinstalan solas al iniciar sesión en Brave. Las que se usan: gestor de contraseñas, bloqueador extra y lector de PDF. No se guardan en el repo.

### Widevine / DRM

Brave instala Widevine la primera vez que se abre Netflix, Spotify Web o similar. Si falla:

```bash
sudo apt-get install -y libffmpegthumbnailer4v5
# y en brave://settings/extensions activar "Widevine"
```

## Firefox (secundario)

- Versión de los repos de Mint con locales en español.
- Se usa para cuentas de trabajo, perfiles aislados y como respaldo si Brave falla.

```bash
firefox --version                  # Mozilla Firefox 159.0.1
```

### Ajustes

- `about:preferences → General → Language`: español de México.
- `about:config` → `browser.tabs.loadInBackground = true` si se quiere abrir en segundo plano.
- Perfil en `~/.mozilla/firefox/`; no se versiona.

## Cambiar el navegador predeterminado

```bash
# Ver el actual
xdg-settings get default-web-browser

# Poner Brave
xdg-settings set default-web-browser brave-browser.desktop

# Poner Firefox
xdg-settings set default-web-browser firefox.desktop
```

También desde `Menú → Preferencias → Aplicaciones preferidas → Web`.

## Problemas

| Síntoma                                 | Solución                                                            |
| --------------------------------------- | ------------------------------------------------------------------- |
| Brave no arranca tras actualizar        | `sudo apt-get install -f` y `sudo apt-get --reinstall install brave-browser` |
| Error de clave GPG del repo de Brave    | Reimportar la clave (ver [02 · Aplicaciones](../02-aplicaciones/))  |
| Los enlaces se abren en el navegador equivocado | `xdg-settings set default-web-browser ...`                  |
| Netflix/Spotify no reproducen           | Activar Widevine y reiniciar el navegador                           |
| Audio no suena solo en el navegador     | Revisar `pavucontrol` → pestaña *Playback*                          |
