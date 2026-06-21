# NextCloud

Quickly deploy a local [NextCloud](https://nextcloud.com/) instance.

```bash
# Run the following commands as root
mkdir /root/nextcloud
cp docker/nextcloud.compose.yaml /root/nextcloud
cd /root/nextcloud
mkdir data
docker compose up -d
```

Access the UI at `http://localhost:8088`.

User guide and advanced setups: [documentation](https://docs.nextcloud.com/).
