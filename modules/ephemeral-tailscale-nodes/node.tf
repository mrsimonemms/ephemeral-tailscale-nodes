# Copyright 2024 Simon Emms <simon@simonemms.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "civo_ssh_key" "ssh_key" {
  name       = "Tailscale"
  public_key = var.ssh_public_key
}

resource "random_integer" "id" {
  for_each = local.nodes

  min = 1000
  max = 9999
}

resource "civo_network" "tailscale" {
  for_each = local.nodes

  label  = "tailscale-${each.value.region}-${random_integer.id[each.key].result}"
  region = each.value.region
}

resource "civo_firewall" "tailscale" {
  for_each = local.nodes

  name                 = "tailscale-${each.value.region}-${random_integer.id[each.key].result}"
  network_id           = civo_network.tailscale[each.key].id
  region               = each.value.region
  create_default_rules = false

  ingress_rule {
    protocol   = "tcp"
    port_range = "22"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }

  ingress_rule {
    protocol   = "udp"
    port_range = "41641"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }

  ingress_rule {
    protocol   = "udp"
    port_range = "3478"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }

  egress_rule {
    label      = "all"
    protocol   = "tcp"
    port_range = "1-65535"
    cidr       = ["0.0.0.0/0"]
    action     = "allow"
  }
}

data "civo_disk_image" "ubuntu" {
  for_each = local.nodes

  filter {
    key    = "name"
    values = ["ubuntu-jammy"]
  }

  region = each.value.region
}

resource "civo_instance" "node" {
  for_each = local.nodes

  hostname    = "tailscale-${each.value.region}-${random_integer.id[each.key].result}"
  tags        = ["tailscale"]
  notes       = "Tailscale exit node"
  firewall_id = civo_firewall.tailscale[each.key].id
  network_id  = civo_network.tailscale[each.key].id
  size        = each.value.size
  disk_image  = data.civo_disk_image.ubuntu[each.key].diskimages[0].id
  region      = each.value.region
  sshkey_id   = civo_ssh_key.ssh_key.id

  script = templatefile("${path.module}/files/cloud-config.tpl.sh", {
    args = "--auth-key=${var.auth_key} --advertise-exit-node"
  })
}
