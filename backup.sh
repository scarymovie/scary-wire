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

SERVER_DIR="/etc/wireguard"
BACKUP_DIR="$HOME/wireguard-backup-$(date +%Y%m%d-%H%M%S)"

echo -e "${GREEN}Создание резервной копии WireGuard...${NC}"

mkdir -p "$BACKUP_DIR"

# Копирование всех конфигураций и ключей
cp -r $SERVER_DIR/* "$BACKUP_DIR/"

# Создание архива
ARCHIVE="$HOME/wireguard-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$ARCHIVE" -C "$(dirname $BACKUP_DIR)" "$(basename $BACKUP_DIR)"

# Удаление временной директории
rm -rf "$BACKUP_DIR"

echo -e "${GREEN}Резервная копия создана: $ARCHIVE${NC}"
echo -e "${YELLOW}Для восстановления используйте: tar -xzf $ARCHIVE -C /tmp && sudo cp -r /tmp/wireguard-backup-*/* /etc/wireguard/${NC}"
