locals {
  subnet_label_counts_file = "${path.cwd}/subnet_label_counts.json"
  subnets_file             = "${path.cwd}/subnets.json"
}

resource local_file subnet_label_counts {
  filename = local.subnet_label_counts_file

  content = jsonencode(var.subnet_label_counts)
}

resource local_file subnets {
  filename = local.subnets_file

  content = jsonencode(var.subnets)
}
