# IBM Cloud VPC module

Provisions a VPC instance and related resources. The full list of resources provisioned is as follows:

- VPC instance
- VPC network acl
- VPC security group rules
    - *ping* - icmp type 8
    - *public dns* - `161.26.0.10` and `161.26.0.11`
    - *private dns* - `161.26.0.7` and `161.26.0.8`

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v13

### Terraform providers

- IBM Cloud provider >= 1.22.0

## Module dependencies

- Resource group - github.com/cloud-native-toolkit/terraform-ibm-resource-group.git

## Example usage

```hcl-terraform
module "dev_vpc" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc.git"
  
  resource_group_id   = module.resource_group.id
  resource_group_name = module.resource_group.name
  region              = var.region
  name_prefix         = var.name_prefix
  ibmcloud_api_key    = var.ibmcloud_api_key
}
```
