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

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Использование: $0 <имя_клиента>${NC}"
    exit 1
fi

CLIENT_NAME=$1
SERVER_DIR="/etc/wireguard"
WG_CONFIG="$SERVER_DIR/wg0.conf"

CLIENT_PUBLIC_KEY="$SERVER_DIR/${CLIENT_NAME}_public.key"

if [ ! -f "$CLIENT_PUBLIC_KEY" ]; then
    echo -e "${RED}Клиент $CLIENT_NAME не найден!${NC}"
    exit 1
fi

CLIENT_PUB=$(cat $CLIENT_PUBLIC_KEY)

echo -e "${YELLOW}Удаление клиента: $CLIENT_NAME${NC}"

sed -i "/^### Client $CLIENT_NAME/,/^$/d" $WG_CONFIG
sed -i "/PublicKey = $CLIENT_PUB/,+1d" $WG_CONFIG

rm -f "$SERVER_DIR/${CLIENT_NAME}_private.key"
rm -f "$SERVER_DIR/${CLIENT_NAME}_public.key"
rm -f "$SERVER_DIR/${CLIENT_NAME}.conf"

systemctl restart wg-quick@wg0

echo -e "${GREEN}Клиент $CLIENT_NAME удален успешно!${NC}"
