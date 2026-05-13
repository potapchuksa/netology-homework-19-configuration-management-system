# Развертывание стека мониторинга (ClickHouse, Vector, Lighthouse).

Ansible проект для развертывания стека мониторинга: **ClickHouse** (хранилище), **Vector** (сбор логов), **Lighthouse** (веб-интерфейс).

## Быстрый старт

```bash
# 1. Установить зависимости (внешние и кастомные роли)
ansible-galaxy install -r requirements.yml -p roles/

# 2. Запустить развертывание
ansible-playbook site.yml

# 3. Или выборочно по тегам
ansible-playbook site.yml --tags vector
ansible-playbook site.yml --tags lighthouse
```

## Правки внешней роли ClickHouse

### Для AlmaLinux / RHEL (RPM)

1. `group_vars/clickhouse/vars.yml`:

```yaml
clickhouse_repo_key: "https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key"
clickhouse_repo_gpgcheck: false
```

2. `roles/clickhouse/tasks/install/dnf.yml` (строка ~15):

```diff
- gpgcheck: 1
+ repo_gpgcheck: 1
+ gpgcheck: 0
```

*Причина*: пакеты в `lts`-репозитории не подписаны, роль не позволяет управлять проверкой через переменные.

### Для Debian / Ubuntu (APT)

1. `group_vars/clickhouse/vars.yml`:

```yaml
clickhouse_repo: "deb https://packages.clickhouse.com/deb stable main"
clickhouse_repo_key: "8919F6BD2B48D754"
```

2. `site.yml` — добавить `pre_tasks` для установки `gnupg`:

```yaml
- name: Install ClickHouse
  hosts: clickhouse
  become: true
  
  pre_tasks:
    - name: Install gnupg for APT key import (Debian only)
      ansible.builtin.apt:
        name: gnupg
        state: present
        update_cache: true
      when: ansible_os_family == "Debian"
  
  roles:
    - clickhouse
```

*Причина*: минимальные облачные образы **Debian** не содержат `gnupg`, необходимый для импорта ключа репозитория.

## Требования

- `Ansible >= 2.9`
- `Python >= 3.6` на целевых хостах
- `Target OS: Linux with systemd` на целевом хосте `Vector`

## Лицензия

MIT — образовательный проект, курс Нетология.

## Автор

Потапчук Сергей.






