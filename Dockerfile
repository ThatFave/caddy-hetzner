FROM golang:1.22 as builder

RUN apt update && \
    apt install -y debian-keyring debian-archive-keyring apt-transport-https && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-xcaddy-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-xcaddy.list && \
    apt update && \
    apt install xcaddy && \
    xcaddy build --with github.com/caddy-dns/hetzner

FROM alpine

LABEL org.opencontainers.image.title=Caddy

COPY --from=builder caddy /srv

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]