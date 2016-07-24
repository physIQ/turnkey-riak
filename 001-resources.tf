provider "google" {
 credentials = "${file("account.json")}"
 project = "${var.ProjectName}"
 region = "${var.RegionInfo.region}"
}

resource "google_compute_network" "public" {
  name = "${var.StackName}"
}

resource "google_compute_subnetwork" "public" {
  name = "${var.StackName}"
  ip_cidr_range = "${var.ipv4_range}"
  network = "${google_compute_network.public.self_link}"
  region = "${var.RegionInfo.region}"
}

resource "google_compute_firewall" "ssh" {
  name = "${var.StackName}-pub-ssh"
  network = "${google_compute_network.public.name}"
  source_ranges = ["${split(",",var.trusted_ips)}"]

  allow {
      protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["22", "80", "443","4980","8000","8087","8098"]
  }

}

resource "google_compute_firewall" "internal" {
  name = "${var.StackName}-internal-allowed"
  network = "${google_compute_network.public.name}"
  source_ranges = ["${var.ipv4_range}"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }

  source_tags = ["internal"]
}

resource "google_storage_bucket" "riak" {
  name = "${var.StackName}"
  force_destroy = "true"
	
  provisioner "local-exec" { 
    command = "gsutil -m cp -r ${var.salt_dir} gs://${var.StackName}"
  }
}

resource "template_file" "master_startup" {
  template = "${file("templates/master_startup.tmpl")}"
	
  vars {
    bucket_name = "${var.StackName}"
    stack_name = "${var.StackName}"
    salt_profiles = "${var.salt_profiles.monitor}"
  }
}

resource "google_compute_instance" "monitor" {
  name = "${format("${var.StackName}-monitor")}"
  machine_type = "${var.machine_types.monitor}"
  zone = "${var.RegionInfo.zone}"
  disk {
    image = "${var.google_image}"
  }
  network_interface = {
    subnetwork = "${var.StackName}"
    access_config {}
  }
    
  metadata {
    startup-script = "${template_file.master_startup.rendered}"
  }

  service_account {
    scopes = ["storage-ro"]
  }

  tags = ["${var.StackName}"]

  depends_on = ["google_compute_subnetwork.public", "template_file.master_startup"]

}

