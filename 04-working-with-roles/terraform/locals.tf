locals {
  vm_names = toset(flatten(values(var.vm_groups_map)))

  vm_metadata = merge(
    var.metadata,
    { ssh-keys = "${var.vm_user}:${file(pathexpand(var.ssh_public_key_path))}" }
  )
}
