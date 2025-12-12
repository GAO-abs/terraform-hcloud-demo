variable "name" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "bandwidth_name1" {}
variable "bandwidth_name2" {}
variable "local_subnets" {
  description = "List of local subnets (CIDR blocks) in the VPC associated with the VPN gateway"
  type        = list(string)
}
variable "ha_mode" {}