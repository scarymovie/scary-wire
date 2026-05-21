# 🔐 WireGuard VPN - Автоматическое развертывание

Полный набор bash-скриптов для быстрого развертывания и управления WireGuard VPN сервером на Linux.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://www.linux.org/)
[![WireGuard](https://img.shields.io/badge/WireGuard-VPN-green.svg)](https://www.wireguard.com/)

## ✨ Особенности

- 🚀 **Быстрая установка** - развертывание за 2-5 минут
- 🔧 **Автоматическая настройка** - firewall, IP forwarding, NAT
- 📱 **QR коды** - для быстрого подключения мобильных устройств
- 👥 **Управление клиентами** - добавление, удаление, список
- 📊 **Мониторинг** - отслеживание подключений в реальном времени
- 💾 **Резервное копирование** - автоматическое сохранение конфигураций
- 📖 **Полная документация** - на русском языке

## 📋 Требования

### Сервер
- **ОС**: Ubuntu 20.04+, Debian 10+, CentOS 8+, RHEL 8+
- **RAM**: минимум 512 MB
- **CPU**: 1 ядро (рекомендуется 2+)
- **Сеть**: публичный IP адрес, открытый UDP порт 51820

### Клиенты
- Linux, Windows, macOS, Android, iOS

## 🚀 Быстрый старт

### Установка за одну команду

```bash
sudo bash setup-wireguard.sh
```

После установки вы получите:
- ✅ Работающий WireGuard VPN сервер
- ✅ 3 готовых клиента (client1, client2, mobile)
- ✅ QR коды для мобильных устройств
- ✅ Настроенный firewall и маршрутизацию

### Интерактивное меню

```bash
sudo bash quick-start.sh
```

### Справка по командам

```bash
bash help.sh
```

## 📦 Основные команды

### Управление клиентами

```bash
# Добавить клиента
sudo bash add-client.sh laptop 10.0.0.5

# Показать QR код
sudo bash show-qr.sh laptop

# Список всех клиентов
sudo bash list-clients.sh

# Удалить клиента
sudo bash remove-client.sh laptop
```

### Мониторинг

```bash
# Мониторинг в реальном времени
sudo bash monitor.sh

# Проверка статуса
sudo bash check-status.sh

# Генерация отчета
sudo bash generate-report.sh
```

### Резервное копирование

```bash
# Создать резервную копию
sudo bash backup.sh

# Восстановить из резервной копии
sudo bash restore.sh /path/to/backup.tar.gz
```

## 📱 Подключение клиентов

### Android/iOS

1. Установите приложение WireGuard из магазина
2. На сервере выполните:
   ```bash
   sudo bash show-qr.sh client1
   ```
3. Отсканируйте QR код в приложении
4. Активируйте туннель

### Windows

1. Скачайте [WireGuard для Windows](https://www.wireguard.com/install/)
2. Скопируйте конфигурацию с сервера:
   ```bash
   sudo cat /etc/wireguard/client1.conf
   ```
3. Импортируйте в приложение
4. Активируйте туннель

### Linux

```bash
# Установите WireGuard
sudo apt install wireguard

# Скопируйте конфигурацию
sudo scp root@SERVER_IP:/etc/wireguard/client1.conf /etc/wireguard/wg0.conf

# Подключитесь
sudo wg-quick up wg0
```

## 📚 Документация

- [📖 README.md](README.md) - Основная документация (этот файл)
- [⚡ QUICKSTART.md](QUICKSTART.md) - Быстрый старт
- [📥 INSTALL.md](INSTALL.md) - Подробное руководство по установке
- [❓ FAQ.md](FAQ.md) - Часто задаваемые вопросы
- [📊 SUMMARY.md](SUMMARY.md) - Сводка проекта
- [📝 CHANGELOG.md](CHANGELOG.md) - История изменений
- [🌍 RU_BYPASS.md](RU_BYPASS.md) - Обход .ru и .рф доменов

## 🛠️ Структура проекта

```
wireguard/
├── setup-wireguard.sh       # Основной скрипт установки
├── quick-start.sh            # Интерактивное меню
├── add-client.sh             # Добавление клиента
├── remove-client.sh          # Удаление клиента
├── list-clients.sh           # Список клиентов
├── show-qr.sh                # Показать QR код
├── monitor.sh                # Мониторинг
├── check-status.sh           # Проверка статуса
├── backup.sh                 # Резервное копирование
├── restore.sh                # Восстановление
├── update-endpoint.sh        # Обновление IP
├── generate-report.sh        # Генерация отчетов
├── setup-split-tunnel.sh     # Настройка split-tunnel
├── test-connection.sh        # Тест соединения
├── uninstall.sh              # Удаление
└── help.sh                   # Справка по командам
```

## 🌐 Сетевые настройки

- **Сервер**: 10.0.0.1/24
- **Клиенты**: 10.0.0.2 - 10.0.0.254
- **Порт**: 51820/udp
- **DNS**: 1.1.1.1, 8.8.8.8

## 🔐 Безопасность

- Все ключи хранятся с правами 600
- Автоматическая настройка firewall
- NAT masquerading для безопасной маршрутизации
- Perfect Forward Secrecy
- Современная криптография (ChaCha20, Poly1305, Curve25519)

## ⚡ Производительность

- **Пропускная способность**: до 1 Гбит/с
- **Задержка**: < 1ms overhead
- **CPU**: низкое потребление
- **Клиенты**: до 253 одновременно

## 🔧 Управление сервисом

```bash
# Запуск/остановка
sudo systemctl start wg-quick@wg0
sudo systemctl stop wg-quick@wg0
sudo systemctl restart wg-quick@wg0

# Автозапуск
sudo systemctl enable wg-quick@wg0

# Статус
sudo systemctl status wg-quick@wg0
sudo wg show
```

## 📝 Логи

```bash
# Просмотр логов в реальном времени
sudo journalctl -u wg-quick@wg0 -f

# Последние 50 строк
sudo journalctl -u wg-quick@wg0 -n 50
```

## 🆘 Устранение неполадок

### Клиент не может подключиться

1. Проверьте статус: `sudo bash check-status.sh`
2. Убедитесь, что порт 51820/udp открыт
3. Проверьте публичный IP в конфигурации клиента
4. Просмотрите логи: `sudo journalctl -u wg-quick@wg0 -f`

### Нет доступа к интернету через VPN

1. Проверьте IP forwarding: `sysctl net.ipv4.ip_forward` (должно быть 1)
2. Проверьте NAT правила: `sudo iptables -t nat -L`
3. Убедитесь, что DNS настроен в конфигурации клиента

### Низкая скорость

1. Попробуйте добавить `MTU = 1420` в секцию [Interface]
2. Проверьте загрузку CPU на сервере
3. Проверьте пропускную способность канала

## 🗑️ Удаление

```bash
sudo bash uninstall.sh
```

Скрипт создаст резервную копию перед удалением.

## 📄 Лицензия

MIT License - свободное использование, модификация и распространение.

## 🤝 Вклад

Приветствуются pull requests и issue reports!

## 📞 Поддержка

- **Документация**: README.md, FAQ.md, INSTALL.md
- **Справка**: `bash help.sh`
- **Диагностика**: `sudo bash check-status.sh`

## ⭐ Благодарности

- [WireGuard](https://www.wireguard.com/) - за отличный VPN протокол
- Сообщество Linux - за поддержку и инструменты

---

**Создано**: 2026-05-21  
**Версия**: 1.0.0  
**Автор**: WireGuard VPN Scripts

🚀 **Начните прямо сейчас**: `sudo bash setup-wireguard.sh`
