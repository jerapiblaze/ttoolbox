# base ubuntu
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# install vulkan
RUN apt-get update && apt-get install -y \
    curl tar libvulkan1 vulkan-tools unzip libgomp1\
    && rm -rf /var/lib/apt/lists/*

# download tabby-vulkan
WORKDIR /opt/tabby
RUN curl -L -o tabby.tar.gz https://github.com/TabbyML/tabby/releases/latest/download/tabby_x86_64-manylinux_2_28-vulkan.tar.gz \
    && tar -xvf tabby.tar.gz --strip-components=1 \
    && rm tabby.tar.gz \
    && chmod +x tabby llama-server

# download katana
RUN curl -L https://github.com/projectdiscovery/katana/releases/download/v1.1.2/katana_1.1.2_linux_amd64.zip -o katana.zip \
        && unzip katana.zip katana \
        && mv katana /usr/bin \
        && rm katana.zip

# launch
EXPOSE 8080
CMD ["./tabby", "serve"]