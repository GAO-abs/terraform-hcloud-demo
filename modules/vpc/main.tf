data "huaweicloud_enterprise_project" "myep" {
  name = "george.ajayi"
}
resource "huaweicloud_vpc" "vpc" {
  name = var.vpc_name
  cidr = var.vpc_cidr
  enterprise_project_id = data.huaweicloud_enterprise_project.myep.id
}