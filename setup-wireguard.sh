#!/bin/bash

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== WireGuard VPN Setup Script ===${NC}"

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Этот скрипт должен быть запущен с правами root${NC}"
   exit 1
fi

# Определение сетевого интерфейса
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
echo -e "${YELLOW}Обнаружен сетевой интерфейс: $INTERFACE${NC}"

# Конфигурация
SERVER_DIR="/etc/wireguard"
SERVER_PRIVATE_KEY="$SERVER_DIR/server_private.key"
SERVER_PUBLIC_KEY="$SERVER_DIR/server_public.key"
WG_CONFIG="$SERVER_DIR/wg0.conf"
SERVER_PORT=51820
SERVER_IP="10.0.0.1/24"
CLIENT_DNS="1.1.1.1, 8.8.8.8"

# Установка WireGuard
echo -e "${GREEN}Установка WireGuard...${NC}"
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y wireguard wireguard-tools qrencode
elif command -v yum &> /dev/null; then
    yum install -y epel-release elrepo-release
    yum install -y kmod-wireguard wireguard-tools qrencode
else
    echo -e "${RED}Неподдерживаемый менеджер пакетов${NC}"
    exit 1
fi

# Включение IP forwarding
echo -e "${GREEN}Включение IP forwarding...${NC}"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
sysctl -p

# Генерация ключей сервера
echo -e "${GREEN}Генерация ключей сервера...${NC}"
mkdir -p $SERVER_DIR
cd $SERVER_DIR
umask 077

wg genkey | tee $SERVER_PRIVATE_KEY | wg pubkey > $SERVER_PUBLIC_KEY

SERVER_PRIV=$(cat $SERVER_PRIVATE_KEY)
SERVER_PUB=$(cat $SERVER_PUBLIC_KEY)

# Создание конфигурации сервера
echo -e "${GREEN}Создание конфигурации сервера...${NC}"
cat > $WG_CONFIG <<EOF
[Interface]
Address = $SERVER_IP
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_PRIV
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE

EOF

# Функция создания клиента
create_client() {
    CLIENT_NAME=$1
    CLIENT_IP=$2

    CLIENT_PRIVATE_KEY="$SERVER_DIR/${CLIENT_NAME}_private.key"
    CLIENT_PUBLIC_KEY="$SERVER_DIR/${CLIENT_NAME}_public.key"
    CLIENT_CONFIG="$SERVER_DIR/${CLIENT_NAME}.conf"

    echo -e "${GREEN}Создание клиента: $CLIENT_NAME${NC}"

    # Генерация ключей клиента
    wg genkey | tee $CLIENT_PRIVATE_KEY | wg pubkey > $CLIENT_PUBLIC_KEY

    CLIENT_PRIV=$(cat $CLIENT_PRIVATE_KEY)
    CLIENT_PUB=$(cat $CLIENT_PUBLIC_KEY)

    # Добавление клиента в конфигурацию сервера
    cat >> $WG_CONFIG <<EOF
[Peer]
PublicKey = $CLIENT_PUB
AllowedIPs = $CLIENT_IP/32

EOF

    # Получение публичного IP сервера
    SERVER_PUBLIC_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || echo "YOUR_SERVER_IP")

    # Создание конфигурации клиента
    cat > $CLIENT_CONFIG <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV
Address = $CLIENT_IP/24
DNS = $CLIENT_DNS

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

    # Генерация QR кода
    echo -e "${YELLOW}QR код для $CLIENT_NAME:${NC}"
    qrencode -t ansiutf8 < $CLIENT_CONFIG

    echo -e "${GREEN}Конфигурация клиента сохранена: $CLIENT_CONFIG${NC}"
}

# Создание клиентов по умолчанию
create_client "client1" "10.0.0.2"
create_client "client2" "10.0.0.3"
create_client "mobile" "10.0.0.4"

# Настройка firewall
echo -e "${GREEN}Настройка firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow $SERVER_PORT/udp
    ufw allow OpenSSH
    ufw --force enable
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=$SERVER_PORT/udp
    firewall-cmd --permanent --add-masquerade
    firewall-cmd --reload
fi

# Запуск WireGuard
echo -e "${GREEN}Запуск WireGuard...${NC}"
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Проверка статуса
echo -e "${GREEN}Статус WireGuard:${NC}"
wg show

echo -e "${GREEN}=== Установка завершена! ===${NC}"

# Спрашиваем про настройку обхода российских сайтов
echo -e "\n${YELLOW}Хотите настроить обход .ru и .рф доменов?${NC}"
echo -e "${YELLOW}(Российские сайты будут идти напрямую, остальные через VPN)${NC}"
read -p "Настроить? (y/n): " setup_bypass

if [[ "$setup_bypass" =~ ^[Yy]$ ]]; then
    echo -e "\n${GREEN}Настройка обхода российских доменов...${NC}"
    bash "$(dirname "$0")/setup-ru-bypass.sh"
fi

echo -e "\n${YELLOW}Конфигурационные файлы клиентов находятся в: $SERVER_DIR${NC}"
echo -e "${YELLOW}Для добавления нового клиента используйте: ./add-client.sh <имя> <IP>${NC}"
