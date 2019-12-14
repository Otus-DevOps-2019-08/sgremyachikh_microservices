resource "google_compute_firewall" "prometheus-default" {
  name    = "prometheus-default-allow-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "puma-default" {
  name    = "puma-default-allow-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = var.source_ranges
}
