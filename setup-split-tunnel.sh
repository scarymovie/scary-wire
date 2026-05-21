#!/bin/bash

# Скрипт для настройки split-tunnel (раздельное туннелирование)
# Позволяет направлять через VPN только определенные сети

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Этот скрипт должен быть запущен с правами root${NC}"
   exit 1
fi

if [ "$#" -lt 2 ]; then
    echo -e "${RED}Использование: $0 <имя_клиента> <сети_через_vpn>${NC}"
    echo -e "${YELLOW}Пример: $0 client1 \"10.0.0.0/24, 192.168.1.0/24\"${NC}"
    echo -e "${YELLOW}Для всего трафика: $0 client1 \"0.0.0.0/0, ::/0\"${NC}"
    exit 1
fi

CLIENT_NAME=$1
ALLOWED_IPS=$2

SERVER_DIR="/etc/wireguard"
CLIENT_CONFIG="$SERVER_DIR/${CLIENT_NAME}.conf"
CLIENT_PRIVATE_KEY="$SERVER_DIR/${CLIENT_NAME}_private.key"
SERVER_PUBLIC_KEY=$(cat $SERVER_DIR/server_public.key)
SERVER_PORT=51820
CLIENT_DNS="1.1.1.1, 8.8.8.8"

if [ ! -f "$CLIENT_PRIVATE_KEY" ]; then
    echo -e "${RED}Клиент $CLIENT_NAME не найден!${NC}"
    exit 1
fi

CLIENT_PRIV=$(cat $CLIENT_PRIVATE_KEY)
CLIENT_IP=$(grep "Address" "$CLIENT_CONFIG" | awk '{print $3}')
SERVER_PUBLIC_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)

echo -e "${GREEN}Настройка split-tunnel для клиента: $CLIENT_NAME${NC}"
echo -e "${YELLOW}Через VPN будут направлены: $ALLOWED_IPS${NC}\n"

cat > $CLIENT_CONFIG <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV
Address = $CLIENT_IP
DNS = $CLIENT_DNS

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
AllowedIPs = $ALLOWED_IPS
PersistentKeepalive = 25
EOF

echo -e "${GREEN}Конфигурация обновлена!${NC}"
echo -e "${YELLOW}Новый QR код:${NC}\n"
qrencode -t ansiutf8 < $CLIENT_CONFIG
