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

# Функция для форматирования байтов
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$(($bytes / 1024))KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$(($bytes / 1048576))MB"
    else
        echo "$(($bytes / 1073741824))GB"
    fi
}

while true; do
    clear
    echo -e "${GREEN}=== WireGuard Monitor ===${NC}"
    echo -e "${YELLOW}Обновление каждые 2 секунды (Ctrl+C для выхода)${NC}\n"

    # Статус сервиса
    if systemctl is-active --quiet wg-quick@wg0; then
        echo -e "${GREEN}Статус сервиса: АКТИВЕН${NC}"
    else
        echo -e "${RED}Статус сервиса: НЕАКТИВЕН${NC}"
    fi

    echo -e "\n${BLUE}=== Подключенные клиенты ===${NC}\n"

    # Парсинг вывода wg show
    wg show wg0 dump | tail -n +2 | while IFS=$'\t' read -r public_key preshared_key endpoint allowed_ips latest_handshake rx_bytes tx_bytes persistent_keepalive; do
        # Поиск имени клиента по публичному ключу
        CLIENT_NAME="unknown"
        for key_file in /etc/wireguard/*_public.key; do
            if [ -f "$key_file" ]; then
                if grep -q "$public_key" "$key_file"; then
                    CLIENT_NAME=$(basename "$key_file" _public.key)
                    break
                fi
            fi
        done

        echo -e "${YELLOW}Клиент:${NC} $CLIENT_NAME"
        echo -e "${YELLOW}IP:${NC} $allowed_ips"

        if [ "$latest_handshake" != "0" ]; then
            LAST_SEEN=$(($(date +%s) - latest_handshake))
            echo -e "${YELLOW}Последнее подключение:${NC} ${LAST_SEEN}с назад"
            echo -e "${GREEN}Статус: ОНЛАЙН${NC}"
        else
            echo -e "${RED}Статус: ОФФЛАЙН${NC}"
        fi

        echo -e "${YELLOW}Получено:${NC} $(format_bytes $rx_bytes)"
        echo -e "${YELLOW}Отправлено:${NC} $(format_bytes $tx_bytes)"
        echo ""
    done

    sleep 2
done
