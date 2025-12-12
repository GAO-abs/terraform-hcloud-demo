terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.80.1"
    }
  }
}

# # Configure the HuaweiCloud Provider
# provider "huaweicloud" {
#   region     = "af-south-1"

# }