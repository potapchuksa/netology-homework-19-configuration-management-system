# Развертывание стека мониторинга (ClickHouse, Vector, Lighthouse).

Terraform + Ansible: инфраструктура и конфигурация стека мониторинга (ClickHouse, Vector, Lighthouse).

## Быстрый старт

```bash
# 1. Поднять инфраструктуру (Terraform)
cd terraform/ && terraform init && terraform apply -auto-approve

# 2. Настроить сервисы (Ansible)
cd ../ansible/ && ansible-galaxy install -r requirements.yml -p roles/ && ansible-playbook -i ../terraform/inventory.yml site.yml
```
