# Peer Connection between Europe and US
resource "google_compute_network_peering" "peering-europe-to-us" {
  name         = "peering-europe-to-us"
  network      = google_compute_network.germany-network-tf.self_link
  peer_network = google_compute_network.montreal-network-tf-1.self_link
}
resource "google_compute_network_peering" "peering-us-to-europe" {
  name         = "peering-us-to-europe"
  network      = google_compute_network.montreal-network-tf-1.self_link
  peer_network = google_compute_network.germany-network-tf.self_link
}