resource "google_compute_firewall" "firewall_ssh" {
  name    = "default-allow-ssh-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.source_ranges
}
