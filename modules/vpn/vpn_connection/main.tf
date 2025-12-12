resource "huaweicloud_vpn_connection" "vpn_connect" {
  name                = var.name
  gateway_id          = var.gateway_id
  gateway_ip          = var.gateway_ip
  customer_gateway_id = var.customer_gateway_id
  peer_subnets        = [var.peer_subnet]
  vpn_type            = "static"
  psk                 = var.psk

  ikepolicy {
    authentication_algorithm = "sha2-256"
    authentication_method    = "pre-share"
    encryption_algorithm     = "aes-128"
    ike_version              = "v2"
    lifetime_seconds         = 86400
    pfs                      = "group15"
  }

  ipsecpolicy {
    authentication_algorithm = "sha2-256"
    encapsulation_mode       = "tunnel"
    encryption_algorithm     = "aes-128"
    lifetime_seconds         = 3600
    pfs                      = "group15"
    transform_protocol       = "esp"
  }
}