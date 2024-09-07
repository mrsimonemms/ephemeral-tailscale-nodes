# ephemeral-tailscale-nodes

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_civo"></a> [civo](#requirement\_civo) | >= 1.1.2, < 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.2, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_civo"></a> [civo](#provider\_civo) | 1.1.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [civo_firewall.tailscale](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/firewall) | resource |
| [civo_instance.node](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/instance) | resource |
| [civo_network.tailscale](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/network) | resource |
| [civo_ssh_key.ssh_key](https://registry.terraform.io/providers/civo/civo/latest/docs/resources/ssh_key) | resource |
| [random_integer.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [civo_disk_image.ubuntu](https://registry.terraform.io/providers/civo/civo/latest/docs/data-sources/disk_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_key"></a> [auth\_key](#input\_auth\_key) | Reusable auth key for Tailscale | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Nodes to add to the Tailscale account | <pre>list(object({<br>    region = string<br>    size   = string<br>  }))</pre> | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
