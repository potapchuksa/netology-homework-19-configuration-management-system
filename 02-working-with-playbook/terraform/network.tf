resource "yandex_vpc_network" "lab" {
  name = "ansible-lab-net"
}

resource "yandex_vpc_subnet" "lab" {
  name           = "ansible-lab-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.lab.id
  v4_cidr_blocks = var.default_cidr
}
