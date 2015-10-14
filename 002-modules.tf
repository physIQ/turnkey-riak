module "haproxy-load-balancer" {
  source = "modules/haproxy-pools"
  name = "haproxy"
  zone = "${var.RegionInfo.zone}"
  StackName = "${var.StackName}"
}

module "haproxy" {
  source = "modules/haproxy"
  count = "${var.instance_count.haproxy}"
  name = "haproxy"
  zone = "${var.RegionInfo.zone}"
  google_image = "${var.google_image}"
  StackName = "${var.StackName}"
  ProjectName = "${var.ProjectName}"
  machine_type = "${var.machine_types.haproxy}"
  NetworkName = "${google_compute_network.public.name}"
  salt_profiles = "${var.salt_profiles.haproxy}"
  master_address = "${google_compute_instance.monitor.network_interface.0.address}"
}

module "riak" {
  source = "modules/riak"
  count = "${var.instance_count.riak}"
  name = "riak"
  zone = "${var.RegionInfo.zone}"
  google_image = "${var.google_image}"
  StackName = "${var.StackName}"
  ProjectName = "${var.ProjectName}"
  machine_type = "${var.machine_types.riak}"
  NetworkName = "${google_compute_network.public.name}"
  diskSSD = "${var.riak_disk_sizes.ssd}"
  diskMagnetic = "${var.riak_disk_sizes.magnetic}"
  salt_profiles = "${var.salt_profiles.riak}"
  master_address = "${google_compute_instance.monitor.network_interface.0.address}"
}

module "logging" {
  source = "modules/logging"
  name = "logging"
  zone = "${var.RegionInfo.zone}"
  google_image = "${var.google_image}"
  StackName = "${var.StackName}"
  ProjectName = "${var.ProjectName}"
  machine_type = "${var.machine_types.logging}"
  NetworkName = "${google_compute_network.public.name}"
  salt_profiles = "${var.salt_profiles.logging}"
  master_address = "${google_compute_instance.monitor.network_interface.0.address}"
}

