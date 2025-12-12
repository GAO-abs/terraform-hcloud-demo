resource "huaweicloud_cce_cluster" "test" {
  name                   = var.cluster_name
  flavor_id              = var.cluster_flavor_id
  vpc_id                 = var.vpc_id
  subnet_id              = var.subnet_id
  container_network_type = "eni"

  ##Uncomment this for high-availability
#   masters {
#     availability_zone = "af-south-1a"
#   }
#   masters {
#     availability_zone = "af-south-1b"
#   }
#   masters {
#     availability_zone = "af-south-1c"
#   }
  
  enable_distribute_management = true
  eni_subnet_id          = join(",",  var.eni_subnets)
}

