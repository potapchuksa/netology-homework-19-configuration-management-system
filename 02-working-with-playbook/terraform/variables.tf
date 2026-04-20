variable "auth_key_file" {
  type = string
  default = "~/.authorized_key.json"
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "default_zone" {
  type = string
  default = "ru-central1-a"
}

variable "default_cidr" {
  type = list(string)
  default = ["10.0.1.0/24"]
}

variable "vm_image_family" {
  type = string
  default = "almalinux-8"
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "vm_names" {
  description = "VM names"
  type = set(string)
  default = [ "clickhouse-01", "vector-01" ]
}

variable "vm_spec" {
  description = "Resource configuration for VMs"
  type = object({
    platform_id = string
    resources = object({
      cores         = number
      memory        = number
      core_fraction = number
    })
    disk = object({
      type = string
      size = number
    })
    preemptible = bool
    nat         = bool
  })

  default = {
    platform_id = "standard-v3"
    resources = {
      cores         = 2
      memory        = 4
      core_fraction = 20
    }
    disk = {
      type = "network-hdd"
      size = 10
    }
    preemptible = true
    nat         = true
  }
}

variable "metadata" {
  description = "Metadata for VMs"
  type        = map(string)
  default = {
    serial-port-enable = "1"
  }
}
