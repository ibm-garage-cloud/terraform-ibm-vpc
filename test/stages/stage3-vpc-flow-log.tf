module "cos" {
  source = "github.com/ibm-garage-cloud/terraform-ibm-object-storage.git"

  resource_group_name = var.resource_group_name
  name_prefix         = var.name_prefix
  name                = "flow-log-cos-instance"
}

resource null_resource print_cos_id {
  depends_on = [module.cos.id]
  provisioner "local-exec" {
    command = "echo 'Provisioning bucket into COS instance: ${module.cos.id}'"
  }
}

module "dev_cos_bucket" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-object-storage-bucket.git"

  resource_group_name = module.resource_group.name
  cos_instance_id     = module.cos.id
  name_prefix         = var.name_prefix
  ibmcloud_api_key    = var.ibmcloud_api_key
  name                = "fl-testing"
  region              = var.region
}

resource null_resource print_bucket {
  provisioner "local-exec" {
    command = "echo 'Bucket created: ${module.dev_cos_bucket.bucket_name}'"
  }
}


module "dev_vpc_with_flowlog" {
  source = "./module"


  resource_group_id   = module.resource_group.id
  resource_group_name = module.resource_group.name
  region              = var.region
  name_prefix         = var.name_prefix
  name                = "vpc-with-fl-${module.cos.name}-${length(null_resource.print_bucket)}"
  ibmcloud_api_key    = var.ibmcloud_api_key
  flow-log-cos-bucket-name = module.dev_cos_bucket.bucket_name
}
