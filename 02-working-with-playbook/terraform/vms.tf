data "yandex_compute_image" "base" {
  family = var.vm_image_family
}

resource "yandex_compute_instance" "vm" {
  for_each = var.vm_names

  name        = "vm-${each.key}"
  hostname    = "vm-${each.key}"

  platform_id = var.vm_spec.platform_id

  resources {
    cores         = var.vm_spec.resources.cores
    memory        = var.vm_spec.resources.memory
    core_fraction = var.vm_spec.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.base.image_id
      type = var.vm_spec.disk.type
      size = var.vm_spec.disk.size
    }
  }

  scheduling_policy {
    preemptible = var.vm_spec.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.lab.id
    nat                = var.vm_spec.nat
  }

  metadata = local.vm_metadata
}
