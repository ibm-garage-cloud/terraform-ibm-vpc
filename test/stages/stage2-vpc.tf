module "dev_vpc" {
  source = "./module"

  resource_group_name = var.resource_group_name
  region              = var.region
  name_prefix         = var.name_prefix
  ibmcloud_api_key    = var.ibmcloud_api_key
  subnet_count        = 1
  public_gateway      = var.vpc_public_gateway == "true"
}
