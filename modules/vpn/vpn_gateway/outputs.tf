output "vpn_gateway_id" {
  value = huaweicloud_vpn_gateway.terraform_built_vpn.id
}

output "vpn_gateway_ip1" {
  value = huaweicloud_vpn_gateway.terraform_built_vpn.eip1[0].id
  
}

output "vpn_gateway_ip2" {
  value = huaweicloud_vpn_gateway.terraform_built_vpn.eip2[0].id
}