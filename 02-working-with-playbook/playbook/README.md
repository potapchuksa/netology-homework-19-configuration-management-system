# Ansible Playbook: ClickHouse + Vector

Автоматизирует установку и настройку стека для сбора логов: **ClickHouse** (хранилище) + **Vector** (агент сбора) на AlmaLinux в Яндекс.Облаке.

## Что делает playbook

- **ClickHouse**: устанавливает СУБД, создаёт базу данных `logs`
- **Vector**: скачивает бинарник, деплоит конфиг для сбора логов из `/var/log/**/*.log` и отправки в ClickHouse
- **Интеграция**: Terraform создаёт ВМ и автоматически генерирует Ansible-inventory

## Требования

- Ansible ≥ 2.14
- Terraform ≥ 1.5
- Yandex Cloud CLI (`yc init`)

## Структура

├── terraform/
│ ├── main.tf
│ ├── vms.tf
│ ├── outputs.tf
│ ├── ansible_inventory.tf # генерация inventory
│ └── variables.tf
└── playbook/
  ├── site.yml # точка входа
  ├── vector.yml # playbook для Vector
  ├── templates/
  │ ├── vector.yml.j2
  │ └── vector.service.j2
  ├── group_vars/vector/vars.yml
  └── inventory/
    └── prod_auto.yml # автогенерируемый


## Переменные

### Terraform (`terraform/variables.tf`)
- `vm_names` — имена ВМ (по умолчанию `["clickhouse-01", "vector-01"]`)
- `vm_spec` — параметры ВМ (cores, memory, disk, nat)
- `vm_image_family` — образ ОС (по умолчанию `"almalinux-9-minimal"`)

### Ansible (`group_vars/vector/vars.yml`)
- `vector_version` — версия Vector (по умолчанию `"0.40.0"`)
- `vector_arch` — архитектура (по умолчанию `"x86_64-unknown-linux-musl"`)
- `vector_install_dir` — путь установки (по умолчанию `"/usr/local/bin"`)

## Теги

```bash
# Только Vector
ansible-playbook -i inventory/prod_auto.yml site.yml --tags vector

# Только ClickHouse
ansible-playbook -i inventory/prod_auto.yml site.yml --tags clickhouse

# Пропустить скачивание пакетов
ansible-playbook -i inventory/prod_auto.yml site.yml --skip-tags download
```

## Быстрый старт

### 1. Развернуть инфраструктуру

```bash
cd terraform
terraform init
terraform apply -auto-approve
# Файл ../playbook/inventory/prod_auto.yml создастся автоматически
```
### 2. Запустить playbook

```bash
cd ../playbook

# Проверка (dry-run)
ansible-playbook -i inventory/prod_auto.yml site.yml --check --diff

# Применение
ansible-playbook -i inventory/prod_auto.yml site.yml --diff
```

### 3. Проверить результат

```bash
# ClickHouse
ansible clickhouse -i inventory/prod_auto.yml -m command -a "clickhouse-client -q 'SHOW DATABASES'"

# Vector
ansible vector -i inventory/prod_auto.yml -m command -a "systemctl is-active vector"
```

