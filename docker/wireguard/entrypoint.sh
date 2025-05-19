#!/bin/sh
set -e

cleanup() {
    printf "Stop wg0 interface...\n"
    /usr/bin/wg-quick down wg0 || true
    exit 0
}

trap cleanup INT TERM

[ -f /etc/wireguard/wg0.conf ] || {
    printf "No se encontró /etc/wireguard/wg0.conf\n"
    exit 1
}

printf "Start wg0 interface...\n"
/usr/bin/wg-quick up wg0

tail -f /dev/null &
wait $!