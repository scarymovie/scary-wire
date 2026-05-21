#!/bin/bash

# Скрипт для автоматического обновления конфигурации клиента при смене IP сервера

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Этот скрипт должен быть запущен с правами root${NC}"
   exit 1
fi

SERVER_DIR="/etc/wireguard"
SERVER_PUBLIC_KEY=$(cat $SERVER_DIR/server_public.key)
SERVER_PORT=51820
CLIENT_DNS="1.1.1.1, 8.8.8.8"

# Получение нового публичного IP
NEW_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)

if [ -z "$NEW_IP" ]; then
    echo -e "${RED}Не удалось определить публичный IP${NC}"
    exit 1
fi

echo -e "${GREEN}Обновление конфигураций клиентов...${NC}"
echo -e "${YELLOW}Новый IP сервера: $NEW_IP${NC}\n"

# Обновление всех конфигураций клиентов
for conf in $SERVER_DIR/*.conf; do
    if [ -f "$conf" ] && [ "$(basename $conf)" != "wg0.conf" ]; then
        CLIENT_NAME=$(basename "$conf" .conf)
        CLIENT_PRIVATE_KEY=$(cat "$SERVER_DIR/${CLIENT_NAME}_private.key")
        CLIENT_IP=$(grep "Address" "$conf" | awk '{print $3}')

        echo -e "${YELLOW}Обновление: $CLIENT_NAME${NC}"

        # Создание новой конфигурации
        cat > $conf <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP
DNS = $CLIENT_DNS

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $NEW_IP:$SERVER_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

        echo -e "${GREEN}✓ $CLIENT_NAME обновлен${NC}"
    fi
done

echo -e "\n${GREEN}Все конфигурации обновлены!${NC}"
echo -e "${YELLOW}Клиенты должны переимпортировать конфигурации или отсканировать новые QR коды${NC}"
