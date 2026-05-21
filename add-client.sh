#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Этот скрипт должен быть запущен с правами root${NC}"
   exit 1
fi

if [ "$#" -ne 2 ]; then
    echo -e "${RED}Использование: $0 <имя_клиента> <IP_адрес>${NC}"
    echo -e "${YELLOW}Пример: $0 laptop 10.0.0.5${NC}"
    exit 1
fi

CLIENT_NAME=$1
CLIENT_IP=$2

SERVER_DIR="/etc/wireguard"
WG_CONFIG="$SERVER_DIR/wg0.conf"
SERVER_PUBLIC_KEY=$(cat $SERVER_DIR/server_public.key)
SERVER_PORT=51820
CLIENT_DNS="1.1.1.1, 8.8.8.8"

CLIENT_PRIVATE_KEY="$SERVER_DIR/${CLIENT_NAME}_private.key"
CLIENT_PUBLIC_KEY="$SERVER_DIR/${CLIENT_NAME}_public.key"
CLIENT_CONFIG="$SERVER_DIR/${CLIENT_NAME}.conf"

if [ -f "$CLIENT_CONFIG" ]; then
    echo -e "${RED}Клиент $CLIENT_NAME уже существует!${NC}"
    exit 1
fi

echo -e "${GREEN}Создание клиента: $CLIENT_NAME с IP: $CLIENT_IP${NC}"

cd $SERVER_DIR
umask 077

wg genkey | tee $CLIENT_PRIVATE_KEY | wg pubkey > $CLIENT_PUBLIC_KEY

CLIENT_PRIV=$(cat $CLIENT_PRIVATE_KEY)
CLIENT_PUB=$(cat $CLIENT_PUBLIC_KEY)

cat >> $WG_CONFIG <<EOF
[Peer]
PublicKey = $CLIENT_PUB
AllowedIPs = $CLIENT_IP/32

EOF

SERVER_PUBLIC_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)

cat > $CLIENT_CONFIG <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV
Address = $CLIENT_IP/24
DNS = $CLIENT_DNS

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

systemctl restart wg-quick@wg0

echo -e "${GREEN}Клиент создан успешно!${NC}"
echo -e "${YELLOW}QR код для $CLIENT_NAME:${NC}"
qrencode -t ansiutf8 < $CLIENT_CONFIG
echo -e "${GREEN}Конфигурация сохранена: $CLIENT_CONFIG${NC}"
