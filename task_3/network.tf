resource "google_compute_address" "germany-vpn-static-ip" {
    name    = "my-germany-vpn-static-ip"
    region  = "europe-west10"
}

resource "google_compute_vpn_gateway" "euro_vpn_gateway" {
    name    = "euro-vpn-gateway"
    network = google_compute_network.germany-network-tf.name
    region  = "europe-west10"
    depends_on = [google_compute_address.germany-vpn-static-ip, google_compute_subnetwork.germany-subnetwork]
}

resource "google_compute_forwarding_rule" "ESPEURO" {
    name = "espeuro"
    region = "europe-west10"
    ip_protocol ="ESP"
    target = google_compute_vpn_gateway.euro_vpn_gateway.self_link
    ip_address = google_compute_address.germany-vpn-static-ip.address
}

resource "google_compute_forwarding_rule" "udp-500-euro" {
    name = "udp-500-euro"
    region = "europe-west10"
    ip_protocol ="UDP"
    port_range = "500"
    target = google_compute_vpn_gateway.euro_vpn_gateway.self_link
    ip_address = google_compute_address.germany-vpn-static-ip.address
}

resource "google_compute_forwarding_rule" "udp-4500-euro" {
    name = "udp-4500-euro"
    region = "europe-west10"
    ip_protocol ="UDP"
    port_range = "4500"
    target = google_compute_vpn_gateway.euro_vpn_gateway.self_link
    ip_address = google_compute_address.germany-vpn-static-ip.address
}

resource "google_compute_vpn_tunnel" "euro_vpn_tunnel" {
    name = "euro-vpn-tunnel"
    region = "europe-west10"
    target_vpn_gateway = google_compute_vpn_gateway.euro_vpn_gateway.id
    peer_ip = google_compute_address.seoul-vpn-static-ip.address
        
    ike_version = 2
    shared_secret = sensitive("secret")
    local_traffic_selector = [ "10.187.1.0/24" ]
    remote_traffic_selector = [ "192.168.11.0/24" ]
    depends_on = [google_compute_forwarding_rule.ESPEURO, google_compute_forwarding_rule.udp-500-euro, google_compute_forwarding_rule.udp-4500-euro, google_compute_forwarding_rule.udp-4500-euro]
}

resource "google_compute_route" "euro-route" {
    name = "euro-route"
    network = google_compute_network.germany-network-tf.name
    dest_range = "192.168.11.0/24"
    next_hop_vpn_tunnel = google_compute_vpn_tunnel.euro_vpn_tunnel.id
    depends_on = [google_compute_vpn_tunnel.euro_vpn_tunnel]    
}

##################################### ASIAN SIDE OF VPN ################################################

resource "google_compute_address" "seoul-vpn-static-ip" {
    name    = "seoul-vpn-static-ip"
    region  = "asia-northeast3"
}

resource "google_compute_vpn_gateway" "asian_vpn_gateway" {
    name    = "asian-vpn-gateway"
    network = google_compute_network.seoul-network-tf.name
    region  = "asia-northeast3"
    depends_on = [google_compute_address.seoul-vpn-static-ip, google_compute_subnetwork.seoul-subnetwork]
}

resource "google_compute_forwarding_rule" "ESPASIA" {
    name = "espasia"
    region = "asia-northeast3"
    ip_protocol ="ESP"
    target = google_compute_vpn_gateway.asian_vpn_gateway.self_link
    ip_address = google_compute_address.seoul-vpn-static-ip.address
}

resource "google_compute_forwarding_rule" "udp-500-asian" {
    name = "udp-500-asian"
    region = "asia-northeast3"
    ip_protocol ="UDP"
    port_range = "500"
    target = google_compute_vpn_gateway.asian_vpn_gateway.self_link
    ip_address = google_compute_address.seoul-vpn-static-ip.address
}

resource "google_compute_forwarding_rule" "udp-4500-asian" {
    name = "udp-4500-asian"
    region = "asia-northeast3"
    ip_protocol ="UDP"
    port_range = "4500"
    target = google_compute_vpn_gateway.asian_vpn_gateway.self_link
    ip_address = google_compute_address.seoul-vpn-static-ip.address
}

resource "google_compute_vpn_tunnel" "asian_vpn_tunnel" {
    name = "asian-vpn-tunnel"
    region = "asia-northeast3"
    target_vpn_gateway = google_compute_vpn_gateway.asian_vpn_gateway.id
    peer_ip = google_compute_address.germany-vpn-static-ip.address
        
    ike_version = 2
    shared_secret = sensitive("secret")
    local_traffic_selector = [ "192.168.11.0/24" ]
    remote_traffic_selector = [ "10.187.1.0/24"  ]
    depends_on = [google_compute_forwarding_rule.ESPASIA, google_compute_forwarding_rule.udp-500-asian, google_compute_forwarding_rule.udp-4500-asian, google_compute_forwarding_rule.udp-4500-asian]
}

resource "google_compute_route" "asian-route" {
    name = "asian-route"
    network = google_compute_network.seoul-network-tf.id
    dest_range = "10.187.1.0/24"
    next_hop_vpn_tunnel = google_compute_vpn_tunnel.asian_vpn_tunnel.id
    depends_on = [google_compute_vpn_tunnel.asian_vpn_tunnel]    
}

