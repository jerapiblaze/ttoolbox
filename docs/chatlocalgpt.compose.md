# Chat-Local-GPT

Quickly deploy [Ollama](https://ollama.com/) and [OpenWebUI](https://openwebui.com/) to get ChatGPT-like experience.

```bash
# Run the following commands as root
mkdir /root/chatlocalgpt
cp docker/chatlocalgpt.compose.yaml /root/chatlocalgpt
cd /root/chatlocalgpt
mkdir data
docker compose up -d
```

Access OpenWebUI at `http://localhost:8800`, access Ollama API at `http://localhost:11434`.

User guide and advanced setups: [OpenWebUI Documentation](https://docs.openwebui.com/) [Ollama Documentation](https://docs.ollama.com/)