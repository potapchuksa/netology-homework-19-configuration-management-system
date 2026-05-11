resource "local_file" "ansible_inventory" {
  content = yamlencode({
    for group, hosts_list in var.vm_groups_map : group => {
      hosts = {
        for name in hosts_list : name => {
          ansible_host = yandex_compute_instance.vm[name].network_interface[0].nat_ip_address
          ansible_user = var.vm_user
        }
      }
    }
  })

  filename = "${path.module}/../ansible/inventory/prod_auto.yml"
}
