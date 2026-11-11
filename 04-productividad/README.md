# 04 · Productividad

Las aplicaciones y ajustes que se usan a diario: navegadores, correo, ofimática, notas, capturas y —lo más importante en este equipo— los **atajos estilo macOS**.

## Aplicaciones

| Tarea                   | Aplicación                        |
| ----------------------- | --------------------------------- |
| Navegador principal     | Brave                             |
| Navegador secundario    | Firefox                           |
| Correo                  | Thunderbird                       |
| Ofimática               | LibreOffice (Writer, Calc, Impress)|
| Notas rápidas           | Sticky Notes                      |
| Notas y Markdown        | Thingy                            |
| PDF                     | Xreader                           |
| Texto plano             | Xed                               |
| Capturas de pantalla    | GNOME Screenshot / `Impr Pant`    |
| Compartir en la LAN     | Warpinator                        |
| Sitios web como apps    | Web App Manager                   |
| TV por internet         | Hypnotix                          |

## Contenido

- [Navegadores](navegadores.md) — Brave, Firefox y aplicación predeterminada.
- [Atajos de teclado](atajos.md) — `⌘Q`, `⌘M`, `⌘Tab`, media pantalla y edición de texto.

## Correo

Thunderbird con las cuentas personales y de trabajo:

```bash
thunderbird &
```

- Firma y plantillas se configuran en `Cuenta → Configuración`.
- El perfil vive en `~/.thunderbird/`; **no** se versiona (contiene credenciales).

## Ofimática

LibreOffice completo:

```bash
sudo apt-get install -y libreoffice-writer libreoffice-calc libreoffice-impress
```

- Formato por defecto: `.odt` / `.ods` / `.odp`; para compartir con Windows se exporta a `.docx` / `.xlsx`.
- Para PDF: `Archivo → Exportar como PDF`.

## Notas

- **Sticky Notes**: post-its en el escritorio para recordatorios rápidos.
- **Thingy**: bloc de notas con Markdown, búsqueda y sincronización local.

## Capturas de pantalla

| Atajo                    | Acción                                  |
| ------------------------ | --------------------------------------- |
| `Impr Pant`              | Captura de toda la pantalla             |
| `Alt+Impr Pant`          | Captura de la ventana activa            |
| `Shift+Impr Pant`        | Seleccionar una zona                     |
| `Ctrl+Shift+Impr Pant`   | Copiar la zona al portapapeles           |

Después se puede anotar con **Drawing**.

## Compartir archivos en la red local

```bash
warpinator &
```

- Ambos equipos deben estar en la misma red y tener Warpinator abierto.
- El firewall debe permitir el puerto `42000/udp` y `42001/tcp` (Mint lo abre al instalar).
- Alternativa por terminal: `python3 -m http.server 8000` y abrir `http://IP:8000` desde el otro equipo.

## Sitios web como aplicaciones

**Web App Manager** crea lanzadores para Gmail, WhatsApp Web, YouTube, etc. Aparecen en el menú como apps independientes, con su propia ventana y sesión.

## Siguiente paso

[05 · IA Local](../05-ia-local/) → OpenCode, MCP y por qué aquí no corre un modelo local.
