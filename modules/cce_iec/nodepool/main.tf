resource "huaweicloud_cce_node_pool" "this" {
  cluster_id               = var.cce_cluster_id
  partition                = var.cce_partition_id

  name                     = var.node_pool_name
  os                       = var.node_os
  initial_node_count       = var.initial_node_count
  flavor_id                = var.node_flavor_id
  availability_zone        = var.zone
  password                 = var.node_password

  scall_enable             = true
  min_node_count           = var.min_node_count
  max_node_count           = var.max_node_count
  scale_down_cooldown_time = 100
  priority                 = 1
  type                     = "vm"

  root_volume {
    size       = var.root_volume_size
    volumetype = "SSD"
  }

  data_volumes {
    size       = var.data_volumes_size
    volumetype = "SSD"
  }
}