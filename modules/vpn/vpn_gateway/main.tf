data "huaweicloud_vpn_gateway_availability_zones" "myaz" {
  flavor          = "professional1"
  attachment_type = "vpc"
}

data "huaweicloud_enterprise_project" "myep" {
  name = "george.ajayi"
}

resource "huaweicloud_vpn_gateway" "terraform_built_vpn" {
  name               = var.name
  vpc_id             = var.vpc_id
  local_subnets      = var.local_subnets
  connect_subnet     = var.subnet_id
  ha_mode            = var.ha_mode
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.myaz.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.myaz.names[1]
  ]
  enterprise_project_id = data.huaweicloud_enterprise_project.myep.id

  eip1 {
    bandwidth_name = var.bandwidth_name1
    type           = "5_bgp"
    bandwidth_size = 5
    charge_mode    = "traffic"
  }

  eip2 {
    bandwidth_name = var.bandwidth_name2
    type           = "5_bgp"
    bandwidth_size = 5
    charge_mode    = "traffic"
  }
}