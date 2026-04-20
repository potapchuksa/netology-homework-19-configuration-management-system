resource "local_file" "ansible_inventory" {
  content = yamlencode({
    clickhouse = {
      hosts = {
        "clickhouse-01" = {
          ansible_host   = yandex_compute_instance.vm["clickhouse-01"].network_interface[0].nat_ip_address
          ansible_user   = "almalinux"
        }
      }
    }
    vector = {
      hosts = {
        "vector-01" = {
          ansible_host   = yandex_compute_instance.vm["vector-01"].network_interface[0].nat_ip_address
          ansible_user   = "almalinux"
        }
      }
    }
  })

  filename = "${path.module}/../playbook/inventory/prod_auto.yml"
}
