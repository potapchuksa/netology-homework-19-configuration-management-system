output "ansible_inventory" {
  description = "Готовый фрагмент для inventory/prod.yml"
  value = <<-EOF
    ---
    clickhouse:
      hosts:
        clickhouse-01:
          ansible_host: ${yandex_compute_instance.vm["clickhouse-01"].network_interface[0].nat_ip_address}
          ansible_user: ${local.vm_user}

    vector:
      hosts:
        vector-01:
          ansible_host: ${yandex_compute_instance.vm["vector-01"].network_interface[0].nat_ip_address}
          ansible_user: ${local.vm_user}
    EOF
}
