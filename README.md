# IBM Cloud VPC module

Provisions a VPC instance and related resources. The full list of resources provisioned is as follows:

- VPC instance
- VPC public gateway (if `public_gateway` is `true`)
- VPC network acl
- VPC subnet (number of instances based on `subnet_count`)
- VPC security group rules
    - *k8s* - tcp ports `30000`-`32767`
    - *ping* - icmp type 8
    - *public dns* - `161.26.0.10` and `161.26.0.11`
    - *private dns* - `161.26.0.7` and `161.26.0.8`

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v12

### Terraform providers

- IBM Cloud provider >= 1.8.1

## Module dependencies

None

## Example usage

```hcl-terraform
vpc "dev_vpc" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc.git?ref=v1.1.0"

  resource_group_name = var.resource_group_name
  region              = var.region
  name_prefix         = var.name_prefix
  ibmcloud_api_key    = var.ibmcloud_api_key
  zone_names          = split(",", var.vpc_zone_names)
  public_gateway      = var.vpc_public_gateway == "true"
  apply               = var.vpc_apply == "true"
}
```
