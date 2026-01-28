FROM debian:bookworm

ADD https://github.com/portainer/portainer/releases/download/2.33.5/portainer-2.33.5-linux-amd64.tar.gz /tmp/portainer.tar.gz

RUN tar -xvf /tmp/portainer.tar.gz -C / && \
    rm /tmp/portainer.tar.gz && \
    apt-get update && apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /data

EXPOSE 9443 8000

WORKDIR /portainer

ENTRYPOINT ["./portainer"]