output "subnet" {
  value = {
    for name, sn in huaweicloud_vpc_subnet.subnet : name => sn.id
  }
}

