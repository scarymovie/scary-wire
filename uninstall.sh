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

echo -e "${RED}=== Удаление WireGuard VPN ===${NC}"
echo -e "${YELLOW}Это действие удалит все конфигурации и ключи!${NC}"
read -p "Вы уверены? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${GREEN}Отменено${NC}"
    exit 0
fi

echo -e "${YELLOW}Создание резервной копии перед удалением...${NC}"
bash backup.sh 2>/dev/null || true

echo -e "${YELLOW}Остановка WireGuard...${NC}"
systemctl stop wg-quick@wg0 || true
systemctl disable wg-quick@wg0 || true

echo -e "${YELLOW}Удаление конфигураций...${NC}"
rm -rf /etc/wireguard/*

echo -e "${YELLOW}Удаление правил firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw delete allow 51820/udp || true
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --remove-port=51820/udp || true
    firewall-cmd --reload || true
fi

echo -e "${YELLOW}Отключение IP forwarding...${NC}"
sed -i '/net.ipv4.ip_forward=1/d' /etc/sysctl.conf
sed -i '/net.ipv6.conf.all.forwarding=1/d' /etc/sysctl.conf
sysctl -p

echo -e "${GREEN}WireGuard успешно удален!${NC}"
echo -e "${YELLOW}Для полного удаления пакета выполните:${NC}"
echo -e "  Ubuntu/Debian: sudo apt remove wireguard wireguard-tools"
echo -e "  CentOS/RHEL: sudo yum remove wireguard-tools kmod-wireguard"
