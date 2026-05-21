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

echo -e "${GREEN}=== Проверка WireGuard VPN ===${NC}\n"

# Проверка установки WireGuard
echo -e "${BLUE}1. Проверка установки WireGuard...${NC}"
if command -v wg &> /dev/null; then
    echo -e "${GREEN}✓ WireGuard установлен${NC}"
    wg --version
else
    echo -e "${RED}✗ WireGuard не установлен${NC}"
fi
echo ""

# Проверка статуса сервиса
echo -e "${BLUE}2. Проверка статуса сервиса...${NC}"
if systemctl is-active --quiet wg-quick@wg0; then
    echo -e "${GREEN}✓ Сервис wg-quick@wg0 активен${NC}"
else
    echo -e "${RED}✗ Сервис wg-quick@wg0 неактивен${NC}"
fi

if systemctl is-enabled --quiet wg-quick@wg0; then
    echo -e "${GREEN}✓ Автозапуск включен${NC}"
else
    echo -e "${YELLOW}⚠ Автозапуск отключен${NC}"
fi
echo ""

# Проверка IP forwarding
echo -e "${BLUE}3. Проверка IP forwarding...${NC}"
IPV4_FORWARD=$(sysctl -n net.ipv4.ip_forward)
if [ "$IPV4_FORWARD" = "1" ]; then
    echo -e "${GREEN}✓ IPv4 forwarding включен${NC}"
else
    echo -e "${RED}✗ IPv4 forwarding отключен${NC}"
fi
echo ""

# Проверка интерфейса
echo -e "${BLUE}4. Проверка интерфейса wg0...${NC}"
if ip link show wg0 &> /dev/null; then
    echo -e "${GREEN}✓ Интерфейс wg0 существует${NC}"
    ip addr show wg0 | grep "inet "
else
    echo -e "${RED}✗ Интерфейс wg0 не найден${NC}"
fi
echo ""

# Проверка firewall
echo -e "${BLUE}5. Проверка firewall...${NC}"
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "51820/udp"; then
        echo -e "${GREEN}✓ UFW: порт 51820/udp открыт${NC}"
    else
        echo -e "${YELLOW}⚠ UFW: порт 51820/udp не найден в правилах${NC}"
    fi
elif command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --list-ports | grep -q "51820/udp"; then
        echo -e "${GREEN}✓ firewalld: порт 51820/udp открыт${NC}"
    else
        echo -e "${YELLOW}⚠ firewalld: порт 51820/udp не найден в правилах${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Firewall не обнаружен${NC}"
fi
echo ""

# Проверка конфигурации
echo -e "${BLUE}6. Проверка конфигурации...${NC}"
if [ -f "/etc/wireguard/wg0.conf" ]; then
    echo -e "${GREEN}✓ Конфигурация /etc/wireguard/wg0.conf существует${NC}"
    PEER_COUNT=$(grep -c "^\[Peer\]" /etc/wireguard/wg0.conf)
    echo -e "${YELLOW}  Количество настроенных клиентов: $PEER_COUNT${NC}"
else
    echo -e "${RED}✗ Конфигурация не найдена${NC}"
fi
echo ""

# Проверка подключений
echo -e "${BLUE}7. Активные подключения...${NC}"
if wg show wg0 &> /dev/null; then
    ACTIVE_PEERS=$(wg show wg0 | grep -c "peer:")
    echo -e "${GREEN}✓ Активных подключений: $ACTIVE_PEERS${NC}"
    wg show wg0
else
    echo -e "${RED}✗ Не удалось получить информацию о подключениях${NC}"
fi
echo ""

# Проверка публичного IP
echo -e "${BLUE}8. Публичный IP сервера...${NC}"
PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me || curl -s --max-time 5 icanhazip.com || echo "не удалось определить")
echo -e "${YELLOW}  $PUBLIC_IP${NC}"
echo ""

# Проверка портов
echo -e "${BLUE}9. Проверка прослушиваемых портов...${NC}"
if ss -ulnp | grep -q ":51820"; then
    echo -e "${GREEN}✓ Порт 51820/udp прослушивается${NC}"
    ss -ulnp | grep ":51820"
else
    echo -e "${RED}✗ Порт 51820/udp не прослушивается${NC}"
fi
echo ""

# Итоговый статус
echo -e "${GREEN}=== Проверка завершена ===${NC}"
