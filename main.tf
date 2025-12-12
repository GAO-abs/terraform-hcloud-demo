resource "huaweicloud_vpc" "test" {
  name = "vpc-summit-demo"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "master_node_subnet" {
  name       = "master-node"
  cidr       = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"

  //dns is required for cce node installing
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.21.250"
  vpc_id        = huaweicloud_vpc.test.id
}


resource "huaweicloud_vpc_subnet" "worker_nodes" {
  name              = "worker-nodes-homezone-subnet"
  cidr              = "192.168.2.0/24"
  gateway_ip        = "192.168.2.1"
  vpc_id            = huaweicloud_vpc.test.id
  availability_zone = "af-south-1-los1a"
}
resource "huaweicloud_vpc_subnet" "pods_subnet" {
  name              = "pods-homezone-subnet"
  cidr              = "192.168.3.0/24"
  gateway_ip        = "192.168.3.1"
  vpc_id            = huaweicloud_vpc.test.id
  availability_zone = "af-south-1-los1a"
}

resource "huaweicloud_vpc_subnet" "pods_subnet2" {
  name              = "pods-homezone-subnet2"
  cidr              = "192.168.5.0/24"
  gateway_ip        = "192.168.5.1"
  vpc_id            = huaweicloud_vpc.test.id
  availability_zone = "af-south-1-los1a"
}
resource "huaweicloud_vpc_subnet" "pods_subnet3" {
  name       = "pods-central-az-subnet"
  cidr       = "192.168.4.0/24"
  gateway_ip = "192.168.4.1"
  vpc_id     = huaweicloud_vpc.test.id
}



resource "huaweicloud_cce_cluster" "test" {
  name                   = "cluster-summit-bank-demo"
  flavor_id              = "cce.s1.small"
  vpc_id                 = huaweicloud_vpc.test.id
  subnet_id              = huaweicloud_vpc_subnet.master_node_subnet.id
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
  eni_subnet_id = join(",", [
    huaweicloud_vpc_subnet.pods_subnet3.ipv4_subnet_id,
  ])


  lifecycle {
    ignore_changes = [
      // After cluster created, the IEC subnet ID will append to the eni container subnet list.
      eni_subnet_id,
    ]
  }
}





resource "huaweicloud_cce_partition" "test" {
  cluster_id           = huaweicloud_cce_cluster.test.id
  category             = "HomeZone"
  name                 = "af-south-1-los1a"
  partition_subnet_id  = huaweicloud_vpc_subnet.worker_nodes.id
  container_subnet_ids = [huaweicloud_vpc_subnet.pods_subnet.ipv4_subnet_id, huaweicloud_vpc_subnet.pods_subnet2.ipv4_subnet_id]
  public_border_group  = "af-south-1-los1"

}

resource "huaweicloud_cce_node_pool" "node_pool" {
  cluster_id               = huaweicloud_cce_cluster.test.id
  name                     = "testpool"
  os                       = "Ubuntu 22.04"
  initial_node_count       = 2
  flavor_id                = "c7n.large.4"
  availability_zone        = "af-south-1-los1a"
  password                 = "Huawei@2024"
  partition                = "af-south-1-los1a"
  scall_enable             = true
  min_node_count           = 1
  max_node_count           = 10
  scale_down_cooldown_time = 100
  priority                 = 1
  type                     = "vm"
  depends_on               = [huaweicloud_cce_partition.test]

  lifecycle {
    ignore_changes = [
      taints,
      labels,
    ]
  }

  root_volume {
    size       = 40
    volumetype = "GPSSD"
  }
  data_volumes {
    size       = 100
    volumetype = "GPSSD"
  }
}




#+------------------------------------------------+
#|                    ELB                         |
#+------------------------------------------------+


# resource "huaweicloud_vpc_eip" "dedicated" {
#   publicip {
#     type = "5_bgp-af-south-1-los1a"

#   }
#   bandwidth {
#     share_type  = "PER"
#     name        = "bandwith-summit"
#     size        = 10
#     charge_mode = "traffic"
#   }
# }

# # Elb subnet
# resource "huaweicloud_vpc_subnet" "elb-subnet" {
#   name              = "elb-homezone-subnet"
#   cidr              = "192.168.2.0/24"
#   gateway_ip        = "192.168.2.1"
#   vpc_id            = huaweicloud_vpc.test.id
#   availability_zone = "af-south-1-los1a"
# }
# # Elastic Load Balance with EIP
# resource "huaweicloud_elb_loadbalancer" "basic" {
#   name              = "summit-elb2"
#   cross_vpc_backend = true
#   vpc_id            = huaweicloud_vpc.test.id
#   ipv4_subnet_id    = huaweicloud_vpc_subnet.elb-subnet.ipv4_subnet_id
#   availability_zone = ["af-south-1-los1a"]
#   ipv4_eip_id       = huaweicloud_vpc_eip.dedicated.id
#   l7_flavor_id      = "98480000-53c1-4ee3-a100-6fcdc91174b8"
#   l4_flavor_id      = "bc46db40-511d-4f10-a8d6-45d76632e77e"

# }


# # resource "huaweicloud_elb_certificate" "certificate_1" {
# #   name        = "certificate_1"
# #   description = "terraform test certificate"
# #   domain      = "www.elb.com"

# #   private_key = file("${path.module}/certs/private_key.pem")
# #   certificate = file("${path.module}/certs/certificate.pem")
# # }

# resource "huaweicloud_elb_listener" "basic" {
#   name                        = "basic"
#   description                 = "basic description"
#   protocol                    = "HTTP"
#   protocol_port               = 80
#   loadbalancer_id             = huaweicloud_elb_loadbalancer.basic.id
#   # server_certificate          = huaweicloud_elb_certificate.certificate_1.id
#   advanced_forwarding_enabled = true
#   idle_timeout                = 60
#   request_timeout             = 60
#   response_timeout            = 60

# }



# resource "huaweicloud_elb_pool" "pool_1" {
#   name                = "summit_demo_pool1"
#   protocol            = "HTTP"
#   lb_method           = "ROUND_ROBIN"
#   loadbalancer_id     = huaweicloud_elb_loadbalancer.basic.id
#   slow_start_enabled  = true
#   slow_start_duration = 100
# }

# resource "huaweicloud_elb_pool" "pool_2" {
#   name                = "summit_demo_pool2"
#   protocol            = "HTTP"
#   lb_method           = "ROUND_ROBIN"
#   loadbalancer_id     = huaweicloud_elb_loadbalancer.basic.id
#   slow_start_enabled  = true
#   slow_start_duration = 100
# }


# resource "huaweicloud_elb_l7policy" "policy_1" {
#   name             = "policy_1"
#   action           = "REDIRECT_TO_POOL"
#   priority         = 20
#   description      = "test description"
#   listener_id      = huaweicloud_elb_listener.basic.id
#   redirect_pool_id = huaweicloud_elb_pool.pool_1.id


# }
# resource "huaweicloud_elb_l7policy" "policy_2" {
#   name             = "policy_2"
#   action           = "REDIRECT_TO_POOL"
#   priority         = 21
#   description      = "test description1"
#   listener_id      = huaweicloud_elb_listener.basic.id
#   redirect_pool_id = huaweicloud_elb_pool.pool_2.id


# }


# resource "huaweicloud_elb_l7rule" "l7rule_1" {
#   l7policy_id  = huaweicloud_elb_l7policy.policy_1.id
#   type         = "HOST_NAME"
#   compare_type = "EQUAL_TO"

#   conditions {
#     value = "app1.ralf.com.ng"
#   }
# }
# resource "huaweicloud_elb_l7rule" "l7rule_2" {
#   l7policy_id  = huaweicloud_elb_l7policy.policy_2.id
#   type         = "HOST_NAME"
#   compare_type = "EQUAL_TO"

#   conditions {
#     value = "app2.ralf.com.ng"
#   }
# }

# resource "huaweicloud_elb_member" "member_2" {
#   address       = "192.168.2.165"
#   protocol_port = 3002
#   pool_id       = huaweicloud_elb_pool.pool_1.id
#   subnet_id     = huaweicloud_vpc_subnet.elb-subnet.ipv4_subnet_id
# }

# resource "huaweicloud_elb_member" "member_1" {
#   address       = "192.168.2.84"
#   protocol_port = 3000
#   pool_id       = huaweicloud_elb_pool.pool_2.id
#   subnet_id     = huaweicloud_vpc_subnet.elb-subnet.ipv4_subnet_id
# }
# resource "huaweicloud_elb_monitor" "monitor_1" {
#   pool_id     = huaweicloud_elb_pool.pool_1.id
#   protocol    = "HTTP"
#   interval    = 30
#   timeout     = 20
#   max_retries = 8
#   url_path    = "/date"
#   domain_name = "app1.ralf.com.ng"
#   port        = 3002
#   status_code = "200"
# }

# resource "huaweicloud_elb_monitor" "monitor_2" {
#   pool_id     = huaweicloud_elb_pool.pool_2.id
#   protocol    = "HTTP"
#   interval    = 30
#   timeout     = 20
#   max_retries = 8
#   url_path    = "/time"
#   domain_name = "app2.ralf.com.ng"
#   port        = 3000
#   status_code = "200"
# }

#+------------------------------------------------+
#|                    Modules                     |
#+------------------------------------------------+

# module "cce_cluster" {
#   source = "./modules/cce_iec/cce_cluster"
#   cluster_name = "cce-summit"
#   cluster_flavor_id = "cce.s1.small"
#   vpc_id = huaweicloud_vpc.test.id
#   subnet_id = huaweicloud_vpc_subnet.master_node_subnet.id
#   eni_subnets = [huaweicloud_vpc_subnet.pods_subnet3.ipv4_subnet_id]

# }

# module "cce_iec_partition" {
#   source = "./modules/cce_iec/partition"
#   partition_subnet_id = huaweicloud_vpc_subnet.worker_nodes.id
#   container_subnet_ids = [huaweicloud_vpc_subnet.pods_subnet.ipv4_subnet_id,huaweicloud_vpc_subnet.pods_subnet2.ipv4_subnet_id]
#   cce_cluster_id = module.cce_cluster.cluster_id

# }

# module "huaweicloud_cce_node_pool" {
#   source = "./modules/cce_iec/nodepool"
#   node_pool_name = "testpool"
#   node_os = "Ubuntu 24.04"
#   cce_cluster_id = module.cce_cluster.cluster_id
#   initial_node_count = 2
#   node_flavor_id = "s7n.xlarge.2"
#   zone = "af-south-1-los1a"
#   node_password = "Huawei@4321"
#   cce_partition_id = module.cce_iec_partition.partition_id
#   min_node_count = 1
#   max_node_count = 10
#   data_volumes_size = 40
#   root_volume_size = 40

# }
