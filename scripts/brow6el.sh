#!/bin/bash
#!/bin/zsh
#!/bin/sh

if [ "$1" == "--install" ]; then
	if [ "$(id -u)" -ne 0 ]; then
		echo "please run as root"
		exit;
	fi
	echo "--> installing Brow6el in /opt/brow6el"
	apt-get install -y
	    build-essential cmake git pkg-config curl
	    libsixel-dev
	    libx11-dev libxcomposite-dev libxdamage-dev libxext-dev libxfixes-dev
	    libxrandr-dev libgbm-dev libxcb1-dev
	    libpango1.0-dev libatk1.0-dev libcups2-dev libasound2-dev
	    libnss3-dev libnspr4-dev libglib2.0-dev
	git clone "https://tangled.org/janantos.tngl.sh/brow6el" /tmp/brow6el
	cd /tmp/brow6el
        ./download_cef.sh
	./build.sh
        cp -r build /opt/brow6el
	rm -rf /tmp/brow6el
	echo "--> Brow6el Install: Done."
	exit;
fi
if [ -d "/opt/brow6el" ]; then
	cd /opt/brow6el && ./run_brow6el.sh $@
else
	echo "Brow6el is not installed. Use this script with --install command!"
fi
