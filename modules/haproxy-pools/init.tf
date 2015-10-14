/* Required Variables */
variable "name" {}
variable "zone" {}
variable "StackName" {}

/* Target Pools */
resource "google_compute_target_pool" "haproxy_target_pool"{
	name = "${var.StackName}-${var.name}-target-pool"
	session_affinity = "NONE"
}

/* Forwarding Rules */
// Create static IP so that rules can share the same ip
resource "google_compute_address" "forwarding_addr" {
	name = "${var.StackName}-${var.name}-forwarding-address"
}

resource "google_compute_forwarding_rule" "haproxy_forwarding_rule1"{
	name = "${var.StackName}-${var.name}-forwarding-rule-8098"
	target = "${google_compute_target_pool.haproxy_target_pool.self_link}"
	ip_address = "${google_compute_address.forwarding_addr.address}"
	ip_protocol = "TCP"
	port_range = "8098"
}

resource "google_compute_forwarding_rule" "haproxy_forwarding_rule2"{
	name = "${var.StackName}-${var.name}-forwarding-rule-8087"
	target = "${google_compute_target_pool.haproxy_target_pool.self_link}"
	ip_address = "${google_compute_address.forwarding_addr.address}"
	ip_protocol = "TCP"
	port_range = "8087"
}

resource "google_compute_forwarding_rule" "haproxy_forwarding_rule3"{
	name = "${var.StackName}-${var.name}-forwarding-rule-8093"
	target = "${google_compute_target_pool.haproxy_target_pool.self_link}"
	ip_address = "${google_compute_address.forwarding_addr.address}"
	ip_protocol = "TCP"
	port_range = "8093"
}

output "ip" {
	value = "${var.name}:${google_compute_address.forwarding_addr.address}"
}

