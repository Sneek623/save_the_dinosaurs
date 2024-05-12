output "webserver_output_northamerica-northeast1" {
    value                       = "http://${google_compute_instance.montreal-vm-1.network_interface[0].access_config[0].nat_ip}"
    }

output "internal_ip_northamerica-northeast1" {
    value                       = google_compute_instance.montreal-vm-1.network_interface.0.network_ip
}

output "vpc_name_northamerica-northeast1" {
    value                       = google_compute_network.montreal-network-tf-1.name
}

output "subnet_ip_range_northamerica-northeast1" {
    value                       = google_compute_subnetwork.montreal-subnetwork-1.name
}

