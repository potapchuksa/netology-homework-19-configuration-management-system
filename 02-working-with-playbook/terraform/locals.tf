locals {
  os_default_user = {
    "almalinux-8"   = "almalinux"
    "almalinux-9"   = "almalinux"
    "rocky-9"       = "rocky"
    "ubuntu-2004"   = "ubuntu"
    "ubuntu-2204"   = "ubuntu"
    "debian-11"     = "debian"
    "debian-12"     = "debian"
  }

  vm_user = lookup(local.os_default_user, var.vm_image_family, "root")

  vm_metadata = merge(
    var.metadata,
    { ssh-keys = "${local.vm_user}:${file(pathexpand(var.ssh_public_key_path))}" }
  )
}
