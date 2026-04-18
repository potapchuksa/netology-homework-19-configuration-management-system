#!/usr/bin/env bash
set -euo pipefail

# Переходим в директорию, где лежит скрипт (чтобы запускать из любого места)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

INVENTORY="inventory/prod.yml"
PLAYBOOK="site.yml"

# Массив: имя_контейнера=образ
declare -A IMAGES=(
    [centos7]="centos:7"
    [ubuntu]="ubuntu:22.04"
    [fedora]="pycontribs/fedora"
)

# Функция гарантированной очистки (сработает даже при ошибке или Ctrl+C)
cleanup() {
    echo -e "\nОстанавливаем и удаляем контейнеры..."
    for name in "${!IMAGES[@]}"; do
        docker rm -f "$name" 2>/dev/null || true
    done
    echo "Контейнеры удалены."
}

# Регистрируем ловушку на любой выход из скрипта
trap cleanup EXIT

echo "Удаляем старые контейнеры (если остались)..."
for name in "${!IMAGES[@]}"; do
    docker rm -f "$name" 2>/dev/null || true
done

echo "Запускаем контейнеры..."
for name in "${!IMAGES[@]}"; do
    docker run -d --name "$name" "${IMAGES[$name]}" sleep infinity
done

# Небольшая пауза для инициализации Docker
sleep 5

# Ubuntu minimal не содержит Python, а он нужен Ansible
echo " Устанавливаем Python в ubuntu..."
docker exec ubuntu apt-get update -qq
docker exec ubuntu apt-get install -y -qq python3 > /dev/null

echo "Запускаем Ansible Playbook..."
ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --ask-vault-pass

echo "Готово!"
# cleanup() вызывается автоматически благодаря trap EXIT
