data "huaweicloud_enterprise_project" "myep" {
  name = "george.ajayi"
}
resource "huaweicloud_rds_instance" "instance" {
  name                = var.rds_name
  flavor              = var.rds_flavor
  ha_replication_mode = "async"
  vpc_id              = var.vpc_id
  subnet_id           = var.subnet_id
  security_group_id   = var.secgroup_id
  enterprise_project_id = data.huaweicloud_enterprise_project.myep.id
  availability_zone   = [
    var.availability_zone1,
    var.availability_zone2,
  ]

  db {
    type     = var.db_type
    version  = var.db_version
    password = var.db_password
  }
  volume {
    type = var.volume_type
    size = var.volume_size
  }
  backup_strategy {
    start_time = var.backup_start_time
    keep_days  = var.backup_keep_days
  }
}



