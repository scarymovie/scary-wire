# Быстрый старт

## Установка за 1 команду

```bash
sudo bash setup-wireguard.sh
```

После установки вы получите:
- Работающий WireGuard VPN сервер
- 3 готовых клиента (client1, client2, mobile)
- QR коды для быстрого подключения

## Интерактивное меню

```bash
sudo bash quick-start.sh
```

Выберите нужное действие из меню.

## Основные команды

```bash
# Добавить клиента
sudo bash add-client.sh laptop 10.0.0.5

# Показать QR код
sudo bash show-qr.sh laptop

# Список клиентов
sudo bash list-clients.sh

# Мониторинг
sudo bash monitor.sh

# Проверка статуса
sudo bash check-status.sh

# Резервная копия
sudo bash backup.sh

# Восстановление
sudo bash restore.sh /path/to/backup.tar.gz
```

## Подключение клиента

### Мобильные устройства (Android/iOS)
1. Установите WireGuard из магазина приложений
2. Отсканируйте QR код: `sudo bash show-qr.sh client1`
3. Активируйте туннель

### Linux
```bash
sudo wg-quick up wg0
```

### Windows
1. Скачайте [WireGuard](https://www.wireguard.com/install/)
2. Импортируйте конфигурацию
3. Активируйте туннель

## Требования

- Ubuntu 20.04+ / Debian 10+ / CentOS 8+ / RHEL 8+
- Root доступ
- Открытый UDP порт 51820

## Поддержка

Для получения помощи запустите:
```bash
sudo bash check-status.sh
```
