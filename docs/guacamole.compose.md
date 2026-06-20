# Guacamole docker-compose

Quickly deploy a [`guacamole`](https://github.com/apache/guacamole-server) server instance.

> Apache Guacamole is a clientless remote desktop gateway. It supports standard protocols like VNC, RDP, and SSH.
> We call it clientless because no plugins or client software are required.
> Thanks to HTML5, once Guacamole is installed on a server, all you need to access your desktops is a web browser.

```bash
# Run the following commands as root
mkdir /root/guacamole
cp docker/guacamole.compose.yaml /root/guacamole
cd /root/guacamole
mkdir ./init
mkdir ./data
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > ./init/initdb.sql
docker compose up -d
```

Access `http://localhost:8389` to access the server. The default admin account is `guacadmin/guacadmin`.

User guide and advanced setups: [guacamole documentation](http://guacamole.apache.org/doc/gug/).
