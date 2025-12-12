variable "vpc" {
  description = "The VPC that this subnet is associated with"
}


variable "subnets" {
  type = list(object({
    name              = string
    cidr              = string
    gateway_ip        = string
    availability_zone = string
  }))
}


