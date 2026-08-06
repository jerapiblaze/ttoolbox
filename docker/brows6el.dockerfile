FROM debian:stable-slim AS base
RUN apt-get update && apt-get install -y \
	libsixel-dev \
	libx11-dev libxcomposite-dev libxdamage-dev libxext-dev libxfixes-dev \
	libxrandr-dev libgbm-dev libxcb1-dev \
	libpango1.0-dev libatk1.0-dev libcups2-dev libasound2-dev \
	libnss3-dev libnspr4-dev libglib2.0-dev \
    libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libglib2.0-0 libdbus-1-3 libxkbcommon0 libxkbcommon-x11-0 \
    && rm -rf /var/lib/apt/lists/*

FROM base AS build
RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config curl \
    && rm -rf /var/lib/apt/lists/*
RUN git clone "https://tangled.org/janantos.tngl.sh/brow6el" /tmp/brow6el
WORKDIR /tmp/brow6el
RUN ./download_cef.sh
RUN ./build.sh
RUN cp -r build/ /opt/brow6el

FROM base AS final
WORKDIR /opt/brow6el
COPY --from=build /opt/brow6el/ /opt/brow6el/
CMD ["./run_brow6el.sh"]
