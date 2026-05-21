#!/bin/bash

# Быстрый запуск WireGuard VPN
# Использование: ./quick-start.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== WireGuard Quick Start ===${NC}\n"

# Проверка прав
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Запустите с sudo: sudo bash quick-start.sh${NC}"
   exit 1
fi

# Меню
echo "Выберите действие:"
echo "1) Установить WireGuard VPN"
echo "2) Добавить нового клиента"
echo "3) Показать QR код клиента"
echo "4) Список всех клиентов"
echo "5) Мониторинг подключений"
echo "6) Проверка статуса"
echo "7) Создать резервную копию"
echo "8) Восстановить из резервной копии"
echo "9) Удалить клиента"
echo "10) Обновить IP адрес сервера"
echo "11) Генерировать отчет"
echo "12) Настроить split-tunnel"
echo "13) Настроить обход .ru и .рф доменов"
echo "14) Удалить WireGuard"
echo "0) Выход"
echo ""

read -p "Введите номер: " choice

case $choice in
    1)
        bash setup-wireguard.sh
        ;;
    2)
        read -p "Имя клиента: " client_name
        read -p "IP адрес (например, 10.0.0.5): " client_ip
        bash add-client.sh "$client_name" "$client_ip"
        ;;
    3)
        read -p "Имя клиента: " client_name
        bash show-qr.sh "$client_name"
        ;;
    4)
        bash list-clients.sh
        ;;
    5)
        bash monitor.sh
        ;;
    6)
        bash check-status.sh
        ;;
    7)
        bash backup.sh
        ;;
    8)
        read -p "Путь к файлу резервной копии: " backup_file
        bash restore.sh "$backup_file"
        ;;
    9)
        read -p "Имя клиента для удаления: " client_name
        bash remove-client.sh "$client_name"
        ;;
    10)
        bash update-endpoint.sh
        ;;
    11)
        bash generate-report.sh
        ;;
    12)
        read -p "Имя клиента: " client_name
        read -p "Сети через VPN (например, 10.0.0.0/24, 192.168.1.0/24): " allowed_ips
        bash setup-split-tunnel.sh "$client_name" "$allowed_ips"
        ;;
    13)
        bash setup-ru-bypass.sh
        ;;
    14)
        bash uninstall.sh
        ;;
    0)
        echo -e "${GREEN}Выход${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Неверный выбор${NC}"
        exit 1
        ;;
esac
