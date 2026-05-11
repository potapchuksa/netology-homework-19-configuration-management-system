# Ansible Playbook: ClickHouse + Vector + Lighthouse

Автоматизирует развёртывание стека для сбора, хранения и визуализации логов на серверах **AlmaLinux** в **Yandex Cloud**.

## Подготовка инфраструктуры

Инфраструктура разворачивается через **Terraform** в Yandex Cloud.

### Требования
- Terraform ≥ 1.12.0
- SSH-ключ для доступа к ВМ (`~/.ssh/id_ed25519.pub` по умолчанию)

## Что делает playbook

| Компонент | Действия |
|-----------|----------|
| **ClickHouse** | Скачивает RPM-пакеты (с fallback на `x86_64`), устанавливает СУБД, ожидает готовности порта `9000`, создаёт базу данных `logs` |
| **Vector** | Проверяет наличие бинарника, скачивает архив только при отсутствии, распаковывает в `/usr/local/bin`, деплоит конфигурацию и `systemd`-юнит для сбора логов из `/var/log/**/*.log` |
| **Lighthouse** | Клонирует репозиторий в `/opt/lighthouse`, разворачивает минимальный конфиг Nginx для прямой отдачи статики, настраивает права доступа |

## Структура

```
~/ansible/03-using-ansible/
├── ansible/
│   ├── site.yml              # Entry point Playbook: Clickhouse (импортирует Vector и Lighthouse)
│   ├── vector.yml            # Playbook: Vector
│   ├── lighthouse.yml        # Playbook: Lighthouse + Nginx
│   ├── group_vars/
│   │   ├── clickhouse/vars.yml
│   │   ├── vector/vars.yml
│   │   └── lighthouse/vars.yml
│   ├── templates/
│   │   ├── nginx-lighthouse.conf.j2
│   │   ├── vector.yml.j2
│   │   └── vector.service.j2
│   ├── inventory/
│   │   ├── prod_auto.yml     # Автогенерируется Terraform
│   │   └── prod.yml          # Ручной (резервный)
│   ├── ansible.cfg
│   └── README.md
│
└── terraform/
    ├── providers.tf
    ├── variables.tf
    ├── locals.tf
    ├── network.tf
    ├── vms.tf
    ├── ansible_inventory.tf
    └── outputs.tf
```

## Параметры

### Terraform (`terraform/variables.tf`)
| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `cloud_id` / `folder_id` | ID облака и каталога Yandex Cloud | — |
| `auth_key_file` | Путь к JSON-ключу сервисного аккаунта | `~/.authorized_key.json` |
| `vm_groups_map` | Сопоставление групп Ansible и имён ВМ | `{clickhouse: [clickhouse-01], ...}` |
| `vm_user` | Пользователь для SSH | `almalinux` |
| `vm_spec` | Ресурсы ВМ (платформа, CPU, RAM, диск, preemptible) | 2 vCPU / 4 GB / 10 GB / true |
| `vm_image_family` | Семейство образа ОС | `almalinux-8` |

### Ansible (`group_vars/`)
#### ClickHouse (`clickhouse/vars.yml`)
| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `clickhouse_version` | Версия СУБД | `22.3.3.44` |
| `clickhouse_packages` | Список RPM-пакетов | `client, server, common-static` |

#### Vector (`vector/vars.yml`)
| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `vector_version` | Версия агента | `0.40.0` |
| `vector_arch` | Архитектура бинарника | `x86_64-unknown-linux-musl` |
| `vector_install_dir` | Путь установки | `/usr/local/bin` |
| `vector_config_dir` / `vector_data_dir` | Пути конфигов и данных | `/etc/vector`, `/var/lib/vector` |

#### Lighthouse (`lighthouse/vars.yml`)
| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `lh_repo` | URL Git-репозитория | `https://github.com/VKCOM/lighthouse.git` |
| `lh_src_path` | Путь клонирования | `/opt/lighthouse` |
| `nginx_port` | Порт веб-сервера | `80` |

## Теги

Playbook поддерживает выборочный запуск компонентов:

| Тег | Действие |
|-----|----------|
| `clickhouse` | Установка и настройка ClickHouse (БД) |
| `vector` | Установка и настройка Vector (лог-агент) |
| `lighthouse` | Деплой Lighthouse (веб-интерфейс) и Nginx |

**Примеры использования:**

```bash
# Запустить только Vector
ansible-playbook site.yml --tags vector

# Пропустить ClickHouse
ansible-playbook site.yml --skip-tags clickhouse
```

## Быстрый старт

### 1. Развертывание инфраструктуры
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

*Автоматически создаст 3 ВМ и сгенерирует `../ansible/inventory/prod_auto.yml`.*

### 2. Проверка конфигурации (Dry-run)
```bash
cd ../ansible
ansible-playbook site.yml --check --diff
```

### 3. Применение
```bash
ansible-playbook site.yml --diff
```

### 4. Проверка результата
```bash
# ClickHouse (наличие БД logs)
ansible clickhouse -m command -a "clickhouse-client -q 'SHOW DATABASES'"

# Vector (статус сервиса)
ansible vector -m command -a "systemctl is-active vector"

# Lighthouse (доступность интерфейса)
curl -s -o /dev/null -w "%{http_code}\n" http://<IP-Lighthouse>/
# Ожидаемый ответ: 200
```
