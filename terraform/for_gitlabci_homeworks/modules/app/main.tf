# Создание виртуалки
resource "google_compute_instance" "app" {
  name         = "gitlabci-${var.environment}"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["gitlabci"]
  boot_disk {
    initialize_params {
      # образ диска для ВМ с приложением
      image = "${var.app_disk_image}"
      size  = 50
    }
  }
  network_interface {
    network = "default"
    access_config {
      # указываю использовать внешний ип, созданный отдельным ресурсом до виртуалки
      nat_ip = google_compute_address.app_ip.address
    }
  }
  metadata = {
    ssh-keys = "sgremyachikh:${file(var.public_key_path)}"

  }
}

# создаю внешний ip этой ВМ
resource "google_compute_address" "app_ip" {
  name = "gitlabci-ip-${var.environment}"
}

# правило открытия порта 80 на ВМ с приложением
resource "google_compute_firewall" "firewall_nginx" {
  name    = "allow-gitlabci-80-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = var.source_ranges
  target_tags   = ["gitlabci"]
}
