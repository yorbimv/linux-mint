# Modelos locales (opcional)

No están instalados. Esta página queda como referencia por si algún día se quiere probar IA sin conexión.

## Qué aguanta este hardware

| Modelo               | Tamaño | RAM necesaria | CPU (i5-3210M)        |
| -------------------- | ------ | ------------- | --------------------- |
| Qwen2.5 0.5B         | ~0.4 GB| ~1 GB         | rápido                |
| Qwen2.5 1.5B         | ~1 GB  | ~2 GB         | usable                |
| Llama 3.2 1B         | ~0.8 GB| ~2 GB         | usable                |
| Llama 3.2 3B         | ~2 GB  | ~4 GB         | lento pero funcional  |
| Mistral 7B / Qwen 7B | ~4.5 GB| ~8 GB         | muy lento (~1-3 tok/s)|
| 13B o más            | >8 GB  | >12 GB        | no recomendado        |

La GPU Intel HD 4000 no acelera estos modelos; todo va por CPU.

## Instalar Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama --version
```

Descargar y probar un modelo pequeño:

```bash
ollama pull qwen2.5:1.5b
ollama run qwen2.5:1.5b "Explícame qué es un registro DKMS"
```

Los modelos se guardan en `/usr/share/ollama/.ollama/models` (root) o en `~/.ollama/models` si se ejecuta como usuario. Ocupan varios GB: revisa el espacio antes.

## Instalar llama.cpp (más ligero, sin servicio)

```bash
sudo apt-get install -y build-essential cmake
git clone https://github.com/ggerganov/llama.cpp ~/llama.cpp
cd ~/llama.cpp && cmake -B build && cmake --build build -j4
```

Descarga un `.gguf` (por ejemplo `qwen2.5-1.5b-instruct-q4_k_m.gguf`) y ejecuta:

```bash
./build/bin/llama-cli -m ~/modelos/qwen2.5-1.5b-instruct-q4_k_m.gguf \
  -p "Hola, ¿qué es Linux Mint?" -n 256
```

## Conectarlo a OpenCode

Ollama expone una API compatible con OpenAI en `http://localhost:11434`. En OpenCode se añade como proveedor local en `Settings → Models` (varía según la versión; consulta la documentación de OpenCode).

## Cuándo vale la pena

- **Sí:** privacidad, trabajar sin internet, tareas cortas de clasificación o resumen.
- **No:** programar, razonar sobre repos grandes o conversaciones largas. Para eso, modelos en la nube.

## Desinstalar

```bash
sudo systemctl stop ollama
sudo systemctl disable ollama
sudo rm -rf /usr/share/ollama /etc/systemd/system/ollama.service
rm -rf ~/.ollama
```
