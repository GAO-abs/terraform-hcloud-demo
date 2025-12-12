resource "huaweicloud_cce_partition" "test" {
  cluster_id            = var.cce_cluster_id
  category              = var.partition_category
  name                  = var.partition_name
  partition_subnet_id   = var.partition_subnet_id
  container_subnet_ids  = var.container_subnet_ids
}

