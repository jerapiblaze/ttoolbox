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

User guide and advanced setup: [Tabby Documentation](https://tabby.tabbyml.com/docs).
