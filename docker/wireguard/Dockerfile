FROM alpine:3.14

RUN apk add -U wireguard-tools iproute2

RUN mkdir -p /etc/wireguard

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
