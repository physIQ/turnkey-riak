/* Required Variables */
variable "machine_type" {}
variable "NetworkName" {}
variable "ProjectName" {}
variable "zone" {}
variable "name" {}
variable "StackName" {}
variable "count" {}
variable "google_image" {}
variable "diskSSD" {}
variable "diskMagnetic" {}
variable "salt_profiles" {}
variable "master_address" {}

resource "template_file" "minion_startup" {
        template = "${file("templates/minion_startup.tmpl")}"

        vars {
                stack_name = "${var.StackName}"
                bucket_name = "${var.StackName}"
                master_address = "${var.master_address}"
                salt_profiles = "${var.salt_profiles}"
        }
}

resource "google_compute_disk" "riakDiskSSD" {
        name = "${format("${var.StackName}-${var.name}-%02d-disk-01", count.index+1)}"
        size = "${var.diskSSD}"
        type = "pd-ssd"
        count = "${var.count}"
        zone = "us-central1-b"
}

resource "google_compute_disk" "riakDiskMagnetic" {
        name = "${format("${var.StackName}-${var.name}-%02d-disk-02", count.index+1)}"
        size = "${var.diskMagnetic}"
        type = "pd-standard"
        count = "${var.count}"
        zone = "us-central1-b"
}

resource "google_compute_instance" "instance" {
		name = "${format("${var.StackName}-${var.name}-%02d", count.index+1)}"
		machine_type = "${var.machine_type}"
		zone = "${var.zone}"
		count = "${var.count}"

		disk {
			image = "${var.google_image}"
		}
		disk {
                        disk = "${element(google_compute_disk.riakDiskSSD.*.name, count.index)}"
                        device_name = "tsSSD"
                        auto_delete = false
                }
                disk {
                        disk = "${element(google_compute_disk.riakDiskMagnetic.*.name, count.index)}"
                        device_name = "tsMagnetic"
                        auto_delete = false
                }

		network_interface = {
			subnetwork = "${var.NetworkName}"
			access_config { }
		}

		metadata {
			startup-script = "${template_file.minion_startup.rendered}"
		}

		service_account {
			scopes = ["storage-ro"]
		}

		tags = ["${var.StackName}"]

}

