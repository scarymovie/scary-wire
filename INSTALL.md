# Руководство по установке WireGuard VPN

## Содержание
1. [Требования](#требования)
2. [Быстрая установка](#быстрая-установка)
3. [Ручная установка](#ручная-установка)
4. [Первоначальная настройка](#первоначальная-настройка)
5. [Проверка установки](#проверка-установки)

## Требования

### Сервер
- **ОС**: Ubuntu 20.04+, Debian 10+, CentOS 8+, RHEL 8+
- **RAM**: минимум 512 MB
- **CPU**: 1 ядро (рекомендуется 2+)
- **Диск**: минимум 1 GB свободного места
- **Сеть**: публичный IP адрес, открытый UDP порт 51820

### Права доступа
- Root доступ (sudo)
- SSH доступ к серверу

### Клиенты
- Любая ОС с поддержкой WireGuard (Linux, Windows, macOS, Android, iOS)

## Быстрая установка

### Метод 1: Одна команда (рекомендуется)

```bash
sudo bash setup-wireguard.sh
```

Это установит и настроит:
- WireGuard сервер
- 3 клиента по умолчанию (client1, client2, mobile)
- Firewall правила
- IP forwarding
- Автозапуск сервиса

**Время установки**: 2-5 минут

### Метод 2: Интерактивное меню

```bash
sudo bash quick-start.sh
```

Выберите "1) Установить WireGuard VPN" из меню.

## Ручная установка

### Шаг 1: Клонирование репозитория

```bash
cd /opt
git clone https://github.com/yourusername/wireguard-scripts.git wireguard-vpn
cd wireguard-vpn
```

### Шаг 2: Проверка скриптов

```bash
ls -la *.sh
```

Убедитесь, что все скрипты исполняемые. Если нет:

```bash
chmod +x *.sh
```

### Шаг 3: Запуск установки

```bash
sudo bash setup-wireguard.sh
```

### Шаг 4: Проверка установки

```bash
sudo bash check-status.sh
```

## Первоначальная настройка

### 1. Проверка публичного IP

```bash
curl ifconfig.me
```

Запомните этот IP - он нужен для подключения клиентов.

### 2. Проверка firewall

**UFW (Ubuntu/Debian)**:
```bash
sudo ufw status
sudo ufw allow 51820/udp
sudo ufw allow OpenSSH
sudo ufw enable
```

**firewalld (CentOS/RHEL)**:
```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=51820/udp
sudo firewall-cmd --reload
```

### 3. Проверка IP forwarding

```bash
sysctl net.ipv4.ip_forward
# Должно быть: net.ipv4.ip_forward = 1
```

Если нет:
```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### 4. Получение конфигураций клиентов

**Список клиентов**:
```bash
sudo bash list-clients.sh
```

**QR код для мобильных**:
```bash
sudo bash show-qr.sh client1
```

**Файл конфигурации**:
```bash
sudo cat /etc/wireguard/client1.conf
```

## Проверка установки

### Автоматическая проверка

```bash
sudo bash check-status.sh
```

Скрипт проверит:
- ✅ Установку WireGuard
- ✅ Статус сервиса
- ✅ IP forwarding
- ✅ Интерфейс wg0
- ✅ Firewall правила
- ✅ Конфигурацию
- ✅ Публичный IP
- ✅ Прослушиваемые порты

### Ручная проверка

**1. Статус сервиса**:
```bash
sudo systemctl status wg-quick@wg0
```

**2. Интерфейс**:
```bash
ip addr show wg0
```

**3. Подключенные клиенты**:
```bash
sudo wg show
```

**4. Логи**:
```bash
sudo journalctl -u wg-quick@wg0 -f
```

## Подключение первого клиента

### Linux

1. **Установите WireGuard**:
```bash
sudo apt install wireguard  # Ubuntu/Debian
```

2. **Скопируйте конфигурацию**:
```bash
sudo scp root@SERVER_IP:/etc/wireguard/client1.conf /etc/wireguard/wg0.conf
```

3. **Подключитесь**:
```bash
sudo wg-quick up wg0
```

4. **Проверьте**:
```bash
ping 10.0.0.1
curl ifconfig.me
```

### Windows

1. Скачайте [WireGuard для Windows](https://www.wireguard.com/install/)
2. Скопируйте содержимое `/etc/wireguard/client1.conf` с сервера
3. В приложении: "Add Tunnel" → "Add empty tunnel"
4. Вставьте конфигурацию
5. Нажмите "Activate"

### macOS

1. Установите из App Store: "WireGuard"
2. Скопируйте файл конфигурации
3. Импортируйте в приложение
4. Активируйте туннель

### Android/iOS

1. Установите приложение "WireGuard" из магазина
2. На сервере выполните:
```bash
sudo bash show-qr.sh client1
```
3. Отсканируйте QR код в приложении
4. Активируйте туннель

## Добавление дополнительных клиентов

```bash
sudo bash add-client.sh laptop 10.0.0.5
sudo bash add-client.sh phone 10.0.0.6
sudo bash add-client.sh tablet 10.0.0.7
```

## Устранение проблем при установке

### Ошибка: "Package wireguard not found"

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt update
sudo apt install wireguard
```

**CentOS/RHEL**:
```bash
sudo yum install epel-release elrepo-release
sudo yum install kmod-wireguard wireguard-tools
```

### Ошибка: "Cannot find device wg0"

```bash
sudo modprobe wireguard
sudo systemctl restart wg-quick@wg0
```

### Ошибка: "Permission denied"

Убедитесь, что запускаете с sudo:
```bash
sudo bash setup-wireguard.sh
```

### Ошибка: "Port 51820 already in use"

Проверьте, не запущен ли уже WireGuard:
```bash
sudo systemctl stop wg-quick@wg0
sudo bash setup-wireguard.sh
```

## Следующие шаги

После успешной установки:

1. **Создайте резервную копию**:
```bash
sudo bash backup.sh
```

2. **Настройте мониторинг**:
```bash
sudo bash monitor.sh
```

3. **Прочитайте FAQ**:
```bash
cat FAQ.md
```

4. **Настройте автоматические обновления** (опционально):
```bash
sudo apt install unattended-upgrades  # Ubuntu/Debian
```

## Поддержка

Если возникли проблемы:

1. Запустите диагностику: `sudo bash check-status.sh`
2. Проверьте логи: `sudo journalctl -u wg-quick@wg0 -n 50`
3. Прочитайте FAQ.md
4. Создайте issue на GitHub

## Безопасность после установки

1. **Смените SSH порт** (опционально):
```bash
sudo nano /etc/ssh/sshd_config
# Измените Port 22 на другой
sudo systemctl restart sshd
```

2. **Настройте fail2ban**:
```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
```

3. **Регулярно обновляйте систему**:
```bash
sudo apt update && sudo apt upgrade  # Ubuntu/Debian
sudo yum update  # CentOS/RHEL
```

4. **Храните резервные копии в безопасном месте**

## Удаление

Если нужно удалить WireGuard:

```bash
sudo bash uninstall.sh
```

Скрипт создаст резервную копию перед удалением.
