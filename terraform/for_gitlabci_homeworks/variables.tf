# ID проекта
variable project {
  description = "Project ID"
}
# region
variable region {
  description = "Region"
  default     = "europe-west1-b"
}
# путь до публичного ключа
variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable connection_key {
  description = "private key for provisioners connection"
}
# зона создания инстанса
variable zone {
  description = "instance creation zone"
  default     = "europe-west1-b"
}
# порт приложения
variable "app_port" {
  description = "reddit-hc port"
  default     = 9292
}
# переменная для образа ВМ с приложением
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
# переменная для образа ВМ с бэком
variable db_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-base-db"
}
variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}
variable machine_type {
  description = "type of instance"
  default     = "n1-standard-1"
}
variable "environment" {
  description = "environment type"
  default     = "stage"
}
