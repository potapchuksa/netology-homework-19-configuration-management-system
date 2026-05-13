output "ansible_inventory" {
  description = "Готовый фрагмент для inventory/prod.yml"
  value       = local_file.ansible_inventory.content
}
