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

resource "hcloud_ssh_key" "ssh_key" {
  name       = "Tailscale"
  public_key = var.ssh_public_key
}

resource "random_integer" "id" {
  for_each = local.nodes

  min = 1000
  max = 9999
}

resource "hcloud_firewall" "tailscale" {
  name = "tailscale"

  rule {
    description = "SSH"
    direction   = "in"
    protocol    = "tcp"
    port        = 22
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "Tailscale"
    direction   = "in"
    protocol    = "udp"
    port        = 41641
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "Tailscale"
    direction   = "in"
    protocol    = "udp"
    port        = 3478
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_server" "node" {
  for_each = local.nodes

  name         = "tailscale-${each.value.region}-${random_integer.id[each.key].result}"
  image        = "ubuntu-24.04"
  server_type  = each.value.size
  location     = each.value.region
  ssh_keys     = [hcloud_ssh_key.ssh_key.id]
  firewall_ids = [hcloud_firewall.tailscale.id]

  user_data = templatefile("${path.module}/files/hetzner.yaml", {
    tailscale_up_args = "--auth-key=${var.auth_key} --advertise-exit-node"
  })

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    type = "tailscale"
  }

  lifecycle {
    ignore_changes = [
      ssh_keys
    ]
  }
}
