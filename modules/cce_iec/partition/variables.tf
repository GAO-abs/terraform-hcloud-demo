variable "partition_category" {
  default = "HomeZone"
}

variable "partition_name" {
    default = "af-south-1-los1a"
}

variable "partition_subnet_id" {

  description = "worker nodes in homezone"
}

variable "container_subnet_ids" {
  type = list(string)
  description = "subnet for your pods"
}

variable "cce_cluster_id" {}

