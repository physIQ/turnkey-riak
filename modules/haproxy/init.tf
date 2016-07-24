/* Required Variables */
variable "machine_type" {}
variable "NetworkName" {}
variable "ProjectName" {}
variable "zone" {}
variable "name" {}
variable "StackName" {}
variable "count" {}
variable "google_image" {}
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


resource "google_compute_instance" "instance" {
		name = "${format("${var.StackName}-${var.name}-%02d", count.index+1)}"
		machine_type = "${var.machine_type}"
		zone = "${var.zone}"
		count = "${var.count}"
                can_ip_forward = true

		disk {
			image = "${var.google_image}"
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

		provisioner "local-exec" {
			command = "gcloud compute target-pools add-instances ${var.StackName}-${var.name}-target-pool --instances ${self.id} --zone ${var.zone}"
		}

}

