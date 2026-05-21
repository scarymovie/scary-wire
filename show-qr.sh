#!/bin/bash

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
    echo -e "${YELLOW}Пример: $0 client1${NC}"
    exit 1
fi

CLIENT_NAME=$1
SERVER_DIR="/etc/wireguard"
CLIENT_CONFIG="$SERVER_DIR/${CLIENT_NAME}.conf"

if [ ! -f "$CLIENT_CONFIG" ]; then
    echo -e "${RED}Клиент $CLIENT_NAME не найден!${NC}"
    echo -e "${YELLOW}Доступные клиенты:${NC}"
    ls -1 $SERVER_DIR/*.conf | grep -v wg0.conf | xargs -n1 basename | sed 's/.conf$//'
    exit 1
fi

echo -e "${GREEN}QR код для клиента: $CLIENT_NAME${NC}\n"
qrencode -t ansiutf8 < $CLIENT_CONFIG

echo -e "\n${YELLOW}Конфигурация:${NC}"
cat $CLIENT_CONFIG
