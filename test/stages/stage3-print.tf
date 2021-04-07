module "print-result" {
  source = "./print-module"

  subnet_label_counts = module.dev_vpc.subnet_label_counts
  subnets             = module.dev_vpc.subnets
}
