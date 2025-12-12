# using for each loop
locals {
  subnet_map = { for sn in var.subnets : sn.name => sn }
}

resource "huaweicloud_vpc_subnet" "subnet" {
  for_each = local.subnet_map

  name              = each.value.name
  cidr              = each.value.cidr
  gateway_ip        = each.value.gateway_ip
  vpc_id            = var.vpc
  availability_zone = each.value.availability_zone
}
