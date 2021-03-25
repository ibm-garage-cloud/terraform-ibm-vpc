terraform {
  required_version = ">= 0.12.0"

  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
      version = ">= 1.17"
    }
  }
}
