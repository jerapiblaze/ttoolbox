# Firefox browser-in-browser

Quickly deploy a [Firefox](https://www.mozilla.org/firefox/) instance inside a docker container and run it in a browser window.

> This project provides a lightweight and secure Docker container for [Firefox](https://www.mozilla.org/firefox/).
>
> Access the application's full graphical interface directly from any modern web browser - no downloads, installs, or setup required on the client side - or connect with any VNC client.
> 
> The web interface also offers audio playback, seamless clipboard sharing, an integrated file manager and terminal for accessing the container's files and shell, desktop notifications, and more.
>
> This Docker container is entirely unofficial and not made by the creators of Firefox.

```bash
# Run the following commands as root
mkdir /root/ffbrowser
cp docker/ffbrowser.compose.yaml /root/ffbrowser
cd /root/ffbrowser
mkdir -p ./firefox/config
docker compose up -d
```

User guide and advanced setups: [documentation](https://github.com/jlesage/docker-firefox).
