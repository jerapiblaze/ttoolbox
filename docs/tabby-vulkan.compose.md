# Tabby with vulkan support using Docker Compose

Quickly deploy a [`tabby`](https://github.com/TabbyML/tabby) server instance with vulkan support.

> Tabby is a self-hosted AI coding assistant, offering an open-source and on-premises alternative to GitHub Copilot.

```bash
# Run the following commands as root
mkdir /root/tabby-server
cp -r docker/tabby-vulkan.* /root/tabby-server
cd /root/tabby-server
docker compose up -d
```

Access `http://localhost:8864` to complete first-time setup.

You can change the model selections by editing the command in `tabby-vulkan.compose.yaml` file. My pre-defined in the compose file is optimized for speed. Here is my settings for more precise outputs, with the cost of high latency.

```yaml
services:
  tabby:
    command: >
    sh -c "
      ./tabby serve --model Qwen2.5-Coder-7B --chat-model Qwen2.5-Coder-7B-Instruct --device vulkan
    "
```

User guide and advanced setup: [Tabby Documentation](https://tabby.tabbyml.com/docs).
