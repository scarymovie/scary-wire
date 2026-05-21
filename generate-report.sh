#!/bin/bash

# Скрипт для генерации отчета о использовании VPN

set -e

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
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1024}")KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1048576}")MB"
    else
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1073741824}")GB"
    fi
}

REPORT_FILE="wireguard-report-$(date +%Y%m%d-%H%M%S).txt"

echo -e "${GREEN}Генерация отчета о использовании WireGuard VPN...${NC}\n"

{
    echo "=========================================="
    echo "WireGuard VPN Usage Report"
    echo "Дата: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo ""

    echo "СТАТУС СЕРВЕРА"
    echo "----------------------------------------"
    if systemctl is-active --quiet wg-quick@wg0; then
        echo "Статус: АКТИВЕН"
    else
        echo "Статус: НЕАКТИВЕН"
    fi
    echo "Uptime: $(systemctl show wg-quick@wg0 --property=ActiveEnterTimestamp --value)"
    echo ""

    echo "КОНФИГУРАЦИЯ"
    echo "----------------------------------------"
    SERVER_IP=$(ip addr show wg0 2>/dev/null | grep "inet " | awk '{print $2}')
    echo "IP сервера: ${SERVER_IP:-N/A}"
    echo "Порт: 51820"
    PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me || echo "N/A")
    echo "Публичный IP: $PUBLIC_IP"
    echo ""

    echo "КЛИЕНТЫ"
    echo "----------------------------------------"
    TOTAL_CLIENTS=$(grep -c "^\[Peer\]" /etc/wireguard/wg0.conf 2>/dev/null || echo "0")
    echo "Всего настроено: $TOTAL_CLIENTS"
    echo ""

    echo "АКТИВНЫЕ ПОДКЛЮЧЕНИЯ"
    echo "----------------------------------------"

    if wg show wg0 &> /dev/null; then
        ACTIVE_COUNT=0

        wg show wg0 dump | tail -n +2 | while IFS=$'\t' read -r public_key preshared_key endpoint allowed_ips latest_handshake rx_bytes tx_bytes persistent_keepalive; do
            # Поиск имени клиента
            CLIENT_NAME="unknown"
            for key_file in /etc/wireguard/*_public.key; do
                if [ -f "$key_file" ]; then
                    if grep -q "$public_key" "$key_file"; then
                        CLIENT_NAME=$(basename "$key_file" _public.key)
                        break
                    fi
                fi
            done

            if [ "$latest_handshake" != "0" ]; then
                LAST_SEEN=$(($(date +%s) - latest_handshake))

                if [ $LAST_SEEN -lt 300 ]; then
                    ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
                    echo ""
                    echo "Клиент: $CLIENT_NAME"
                    echo "  IP: $allowed_ips"
                    echo "  Endpoint: ${endpoint:-N/A}"
                    echo "  Последнее подключение: ${LAST_SEEN}с назад"
                    echo "  Получено: $(format_bytes $rx_bytes)"
                    echo "  Отправлено: $(format_bytes $tx_bytes)"
                    echo "  Всего трафика: $(format_bytes $((rx_bytes + tx_bytes)))"
                fi
            fi
        done

        echo ""
        echo "Активных подключений (за последние 5 мин): $ACTIVE_COUNT"
    else
        echo "Нет активных подключений"
    fi

    echo ""
    echo "=========================================="
    echo "Конец отчета"
    echo "=========================================="

} > "$REPORT_FILE"

cat "$REPORT_FILE"

echo -e "\n${GREEN}Отчет сохранен в: $REPORT_FILE${NC}"
