variable "cluster_name" {}
variable "cluster_flavor_id" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "eni_subnets" {
  type = list(string)
}

