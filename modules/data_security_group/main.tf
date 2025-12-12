data "huaweicloud_enterprise_project" "myep" {
  name = "george.ajayi"
}
resource "huaweicloud_networking_secgroup" "data_nsg" {
  name        = var.security_group_name
  description = "Security group for the database subnet in the VPC"
  enterprise_project_id = data.huaweicloud_enterprise_project.myep.id
}

resource "huaweicloud_networking_secgroup_rule" "allow_postgres" {
  security_group_id = huaweicloud_networking_secgroup.data_nsg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_ip_prefix  = "172.0.0.0/16"
}

resource "huaweicloud_networking_secgroup_rule" "allow_mysql" {
  security_group_id = huaweicloud_networking_secgroup.data_nsg.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "172.0.0.0/16"
}