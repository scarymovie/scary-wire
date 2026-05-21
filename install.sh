#!/bin/bash

# Автоматическая установка и настройка WireGuard VPN за один шаг
# Использование: curl -sSL https://your-repo/install.sh | sudo bash

set -e

REPO_URL="https://github.com/yourusername/wireguard-scripts"
INSTALL_DIR="/opt/wireguard-vpn"

echo "=== WireGuard VPN Auto Installer ==="
echo ""

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт должен быть запущен с правами root"
   exit 1
fi

# Установка git если не установлен
if ! command -v git &> /dev/null; then
    echo "Установка git..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y git
    elif command -v yum &> /dev/null; then
        yum install -y git
    fi
fi

# Клонирование репозитория
echo "Загрузка скриптов..."
if [ -d "$INSTALL_DIR" ]; then
    cd $INSTALL_DIR
    git pull
else
    git clone $REPO_URL $INSTALL_DIR
    cd $INSTALL_DIR
fi

# Запуск установки
echo "Запуск установки WireGuard..."
bash setup-wireguard.sh

echo ""
echo "=== Установка завершена! ==="
echo "Для управления используйте: cd $INSTALL_DIR && sudo bash quick-start.sh"
