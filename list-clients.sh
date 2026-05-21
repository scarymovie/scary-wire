#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Этот скрипт должен быть запущен с правами root${NC}"
   exit 1
fi

SERVER_DIR="/etc/wireguard"

echo -e "${GREEN}=== Список клиентов WireGuard ===${NC}\n"

# Список всех конфигурационных файлов клиентов
for conf in $SERVER_DIR/*.conf; do
    if [ -f "$conf" ] && [ "$(basename $conf)" != "wg0.conf" ]; then
        CLIENT_NAME=$(basename "$conf" .conf)
        CLIENT_IP=$(grep "Address" "$conf" | awk '{print $3}' | cut -d'/' -f1)

        echo -e "${BLUE}Клиент:${NC} $CLIENT_NAME"
        echo -e "${YELLOW}IP:${NC} $CLIENT_IP"
        echo -e "${YELLOW}Конфигурация:${NC} $conf"
        echo ""
    fi
done

echo -e "${GREEN}=== Активные подключения ===${NC}\n"
wg show wg0 2>/dev/null || echo -e "${RED}WireGuard не запущен${NC}"
