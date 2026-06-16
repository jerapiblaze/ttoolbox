# Chat-Local-GPT

Quickly deploy [Ollama](https://ollama.com/) and [OpenWebUI](https://openwebui.com/) to get ChatGPT-like experience.

```bash
# Run the following commands as root
mkdir /root/chatlocalgpt
cp -r docker/chatlocalgpt/* /root/chatlocalgpt
cd /root/chatlocalgpt
mkdir data
# if NVIDIA GPU is available
docker compose -f chatlocalgpt.nvidia.compose.yaml up -d
# else, use iGPU with vulkan
docker compose -f chatlocalgpt.vulkan.compose.yaml up -d
```

Access OpenWebUI at `http://localhost:8800`, access Ollama API at `http://localhost:11434`.

User guide and advanced setups: [OpenWebUI Documentation](https://docs.openwebui.com/) [Ollama Documentation](https://docs.ollama.com/)