/* GERMANY */
resource "google_compute_network" "germany-network-tf" {
    name                     = "germany-network-tf"
    auto_create_subnetworks  = false
    routing_mode             = "REGIONAL"
    mtu                      =  1460
}

resource "google_compute_subnetwork" "germany-subnetwork" {
    name                     = "germany-subnetwork"
    network                  =  google_compute_network.germany-network-tf.name
    ip_cidr_range            = "10.187.1.0/24" 
    region                   = "europe-west10"
}

resource "google_compute_firewall" "germany-firewall-rules" {
    network                  =  google_compute_network.germany-network-tf.name
    name                     = "germany-firewall-rules"
allow {
    protocol                 = "tcp"
    ports                    = ["80"]
    }
    source_ranges            = ["35.235.240.0/20", "172.16.1.0/24", "172.16.11.0/24", "192.168.11.0/24"]
} 

resource "google_compute_instance" "germany-vm" {
  boot_disk {
    auto_delete              =  true
    device_name              = "germany-vm"

initialize_params {
    image                    = "projects/debian-cloud/global/images/debian-12-bookworm-v20240415"
    size                     =  10
    type                     = "pd-balanced"
    }

    mode                     = "READ_WRITE"
  }

    can_ip_forward           = false
    deletion_protection      = false
    enable_display           = false

    labels                   = {
    goog-ec-src              = "vm_add-tf"
  }

    machine_type             = "e2-medium"

 /*    metadata                 = {
      startup-script         = file("remo-startup.sh")
    }*/
metadata = {
    startup-script = "#Thanks to Remo I have some code to put in here...\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
    name                     = "germany-vm"

network_interface {
    network                  = google_compute_network.germany-network-tf.name
    subnetwork               = google_compute_subnetwork.germany-subnetwork.name
access_config {
    network_tier             = "PREMIUM"
    }

    queue_count              = 0
    stack_type               = "IPV4_ONLY"
  }

scheduling {
    automatic_restart         =  true
    on_host_maintenance       = "MIGRATE"
    preemptible               =  false
    provisioning_model        = "STANDARD"
  }

  service_account {
    email                       = "578688270847-compute@developer.gserviceaccount.com"
    scopes                      = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

    zone                        = "europe-west10-a"
}

output "webserver_output" {
    value                       = "http://${google_compute_instance.germany-vm.network_interface[0].access_config[0].nat_ip}"
    }

output "internal_ip" {
    value                       = google_compute_instance.germany-vm.network_interface.0.network_ip
}

output "vpc_name" {
    value                       = google_compute_network.germany-network-tf.name
}

output "subnet_ip_range" {
    value                       = google_compute_subnetwork.germany-subnetwork.name
}

#######################################ASIA STARTS HERE!!!#############################################

/* ASIA */

/* resource google_compute_network seoul-network-tf {
    name = "seoul-network-tf"
    auto_create_subnetworks     =  false
    routing_mode                = "REGIONAL"
    mtu                         =   1460
}*/

resource google_compute_network seoul-network-tf {
  name = "seoul-network-tf"
auto_create_subnetworks     =  false
 mtu                         =   1460
 routing_mode                = "REGIONAL"
}

resource "google_compute_subnetwork" "seoul-subnetwork" {
    name                        = "seoul-subnetwork"
    network                     =   google_compute_network.seoul-network-tf.name
    ip_cidr_range               = "192.168.11.0/24" 
    region                      = "asia-northeast3"
}

resource "google_compute_firewall" "seoul-firewall-rules" {
    network                     =  google_compute_network.seoul-network-tf.name
    name                        = "seoul-firewall-rules"
allow {
    protocol                    = "tcp"
    ports                       = ["3389"]
    }
    source_ranges               = ["0.0.0.0/0"]
} 

# Create Asian Virtual Machine Instance

resource "google_compute_instance" "seoul-vm" {
  machine_type                  = "e2-medium"
  name                          = "seoul-vm"
  zone                          = "asia-northeast3-a"
  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
    }
  }
  network_interface {
    access_config {
      network_tier = "STANDARD"
    }
    subnetwork = google_compute_subnetwork.seoul-subnetwork.self_link
        network    = google_compute_network.seoul-network-tf.self_link
  }
}

output "webserver_output_asia" {
    value                       = "http://${google_compute_instance.seoul-vm.network_interface[0].access_config[0].nat_ip}"
    }

output "internal_ip_asia" {
    value                       = google_compute_instance.seoul-vm.network_interface.0.network_ip
}

output "vpc_name_asia" {
    value                       = google_compute_network.seoul-network-tf.name
}

output "subnet_ip_range_asia" {
    value                       = google_compute_subnetwork.seoul-subnetwork.name
}

#######################################AMERICAS-1 START HERE!!!#############################################


/* AMERICAS */

/* resource google_compute_network montreal-network-tf {
    name = "montreal-network-tf"
    auto_create_subnetworks     =  false
    routing_mode                = "REGIONAL"
    mtu                         =   1460
}*/

resource google_compute_network montreal-network-tf-1 {
  name = "montreal-network-tf-1"
auto_create_subnetworks         =  false
 mtu                            =   1460
 routing_mode                   = "REGIONAL"
}

resource "google_compute_subnetwork" "montreal-subnetwork-1" {
    name                        = "montreal-subnetwork-1"
    network                     =   google_compute_network.montreal-network-tf-1.name
    ip_cidr_range               = "172.16.1.0/24" 
    region                      = "northamerica-northeast1"
}

resource "google_compute_firewall" "montreal-firewall-rules-1" {
    network                     =  google_compute_network.montreal-network-tf-1.name
    name                        = "montreal-firewall-rules-1"
allow {
    protocol                    = "tcp"
    ports                       = ["3389"]
    }
    source_ranges               = ["0.0.0.0/0"]
} 

# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

# Create Asian Virtual Machine Instance
resource "google_compute_instance" "montreal-vm-1" {
  machine_type                   = "e2-medium"
  name                           = "montreal-vm"
  zone                           = "northamerica-northeast1-a"
  boot_disk {
    initialize_params {
      image                      = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
    }
  }
  network_interface {
    access_config {
      network_tier                = "STANDARD"
    }
    subnetwork                    = google_compute_subnetwork.montreal-subnetwork-1.self_link
        network                   = google_compute_network.montreal-network-tf-1.self_link
  }
}

#######################################AMERICAS-2 START HERE!!!#############################################


/* AMERICAS-2 */

/* resource google_compute_network montreal-network-tf {
    name = "montreal-network-tf"
    auto_create_subnetworks     =  false
    routing_mode                = "REGIONAL"
    mtu                         =   1460
}*/

/* Using same cloud as AMERICA1 */

resource "google_compute_subnetwork" "montreal-subnetwork-2" {
    name                        = "montreal-subnetwork-2"
    network                     =   google_compute_network.montreal-network-tf-1.name
    ip_cidr_range               = "172.16.11.0/24" 
    region                      = "northamerica-northeast1"
}

resource "google_compute_firewall" "montreal-firewall-rules-2" {
    network                     =  google_compute_network.montreal-network-tf-1.name
    name                        = "montreal-firewall-rules-2"
allow {
    protocol                    = "tcp"
    ports                       = ["3389"]
    }
    source_ranges               = ["0.0.0.0/0"]
} 

# Create AMERICAS-2 Virtual Machine Instance

resource "google_compute_instance" "montreal-vm-2" {
  machine_type                  = "e2-medium"
  name                          = "montreal-vm-2"
  zone                          = "northamerica-northeast1-a"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image                     = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
    }
  }
  network_interface {
    access_config {
      network_tier              = "STANDARD"
    }
    subnetwork                  = google_compute_subnetwork.montreal-subnetwork-2.self_link
        network                 = google_compute_network.montreal-network-tf-1.self_link
  }
}











