
variable "subnet_label_counts" {
  type = list(object({
    label = string
    count = number
  }))
}

variable "subnets" {
  type = list(object({
    id = string
    label = string
  }))
}
