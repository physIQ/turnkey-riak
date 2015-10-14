variable "StackName" {
   default="YOUR_STACK_NAME"
}

variable "ProjectName" {
    default = "YOUR_PROJECT_NAME"
}

# Make sure there are no spaces in your list. Must be in cidr format, e.g. 10.0.0.1/32,192.168.100.0/24
variable "trusted_ips" {
   default = "YOUR_TRUSTED_LIST_HERE"
}

# Number of servers
variable "instance_count" {
   default = {
	riak = 5
	haproxy = 2 
    }
}

variable "machine_types" {
  default = {
   haproxy = "n1-standard-1"
   riak = "n1-standard-2"
   monitor = "n1-standard-2"
   logging = "n1-standard-1"
  }
}

variable "RegionInfo" {
  default = {
	region = "us-central1"
	zone = "us-central1-b"
  }
}

variable "google_image" {
   default = "centos-7-v20150915"
}

variable "salt_dir" {
   default = "salt"
}

variable "ipv4_range" {
   default = "10.218.1.0/24"
}

# Leveldb disk sizes
variable "riak_disk_sizes" {
  default = {
      ssd = 10
      magnetic = 50
  }
}

# Salt profiles
variable "salt_profiles" {
  default = {
	monitor = "monitor"
	haproxy = "haproxy"
	logging = "logging"
	riak = "riak"
   }
}
