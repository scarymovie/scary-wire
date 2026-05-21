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

if [ "$#" -ne 1 ]; then
    echo -e "${RED}Использование: $0 <путь_к_архиву>${NC}"
    echo -e "${YELLOW}Пример: $0 /home/user/wireguard-backup-20260521-120000.tar.gz${NC}"
    exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Файл резервной копии не найден: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}Восстановление WireGuard из резервной копии...${NC}"
echo -e "${RED}ВНИМАНИЕ: Это перезапишет текущую конфигурацию!${NC}"
read -p "Продолжить? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${GREEN}Отменено${NC}"
    exit 0
fi

# Остановка WireGuard
echo -e "${YELLOW}Остановка WireGuard...${NC}"
systemctl stop wg-quick@wg0 || true

# Создание резервной копии текущей конфигурации
if [ -d "/etc/wireguard" ] && [ "$(ls -A /etc/wireguard)" ]; then
    echo -e "${YELLOW}Создание резервной копии текущей конфигурации...${NC}"
    CURRENT_BACKUP="/tmp/wireguard-current-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$CURRENT_BACKUP" -C /etc wireguard
    echo -e "${GREEN}Текущая конфигурация сохранена в: $CURRENT_BACKUP${NC}"
fi

# Распаковка резервной копии
echo -e "${YELLOW}Распаковка резервной копии...${NC}"
TEMP_DIR=$(mktemp -d)
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Поиск директории с конфигурацией
BACKUP_DIR=$(find "$TEMP_DIR" -type d -name "wireguard-backup-*" | head -n1)

if [ -z "$BACKUP_DIR" ]; then
    echo -e "${RED}Неверный формат резервной копии${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Восстановление конфигурации
echo -e "${YELLOW}Восстановление конфигурации...${NC}"
rm -rf /etc/wireguard/*
cp -r "$BACKUP_DIR"/* /etc/wireguard/
chmod 600 /etc/wireguard/*.key /etc/wireguard/*.conf

# Очистка
rm -rf "$TEMP_DIR"

# Запуск WireGuard
echo -e "${YELLOW}Запуск WireGuard...${NC}"
systemctl start wg-quick@wg0

echo -e "${GREEN}Восстановление завершено успешно!${NC}"
wg show
