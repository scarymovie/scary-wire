#!/bin/bash

# Тестирование WireGuard VPN соединения

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== WireGuard VPN Connection Test ===${NC}\n"

# Проверка, запущен ли клиент
if ! ip link show wg0 &> /dev/null; then
    echo -e "${RED}WireGuard интерфейс wg0 не найден${NC}"
    echo -e "${YELLOW}Запустите: sudo wg-quick up wg0${NC}"
    exit 1
fi

echo -e "${BLUE}1. Проверка интерфейса...${NC}"
if ip addr show wg0 | grep -q "inet "; then
    VPN_IP=$(ip addr show wg0 | grep "inet " | awk '{print $2}')
    echo -e "${GREEN}✓ VPN IP: $VPN_IP${NC}"
else
    echo -e "${RED}✗ IP адрес не назначен${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}2. Проверка подключения к серверу...${NC}"
SERVER_IP=$(echo $VPN_IP | cut -d'/' -f1 | cut -d'.' -f1-3).1
if ping -c 3 -W 2 $SERVER_IP &> /dev/null; then
    echo -e "${GREEN}✓ Сервер $SERVER_IP доступен${NC}"
else
    echo -e "${RED}✗ Сервер $SERVER_IP недоступен${NC}"
fi
echo ""

echo -e "${BLUE}3. Проверка DNS...${NC}"
if ping -c 2 -W 2 google.com &> /dev/null; then
    echo -e "${GREEN}✓ DNS работает${NC}"
else
    echo -e "${YELLOW}⚠ Проблемы с DNS${NC}"
fi
echo ""

echo -e "${BLUE}4. Проверка внешнего IP...${NC}"
EXTERNAL_IP=$(curl -s --max-time 5 ifconfig.me || echo "N/A")
echo -e "${YELLOW}Ваш внешний IP: $EXTERNAL_IP${NC}"
echo ""

echo -e "${BLUE}5. Статистика соединения...${NC}"
sudo wg show wg0
echo ""

echo -e "${BLUE}6. Тест скорости (ping)...${NC}"
if ping -c 10 $SERVER_IP &> /dev/null; then
    AVG_PING=$(ping -c 10 $SERVER_IP | tail -1 | awk -F '/' '{print $5}')
    echo -e "${GREEN}Средний ping: ${AVG_PING}ms${NC}"
else
    echo -e "${RED}Не удалось выполнить ping тест${NC}"
fi
echo ""

echo -e "${GREEN}=== Тест завершен ===${NC}"
