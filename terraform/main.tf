terraform {
  # Версия terraform
  required_version = "~>0.12.8"
}

provider "google" {
  # Версия провайдера
  version = "~> 2.15"
  # ID проекта
  project = var.project
  # регион развертывания
  region = var.region
}

# модуль для доступа ко всем ВМ по 22 порту ssh
module "vpc" {
  source        = "./modules/vpc"
  source_ranges = var.source_ranges
  environment   = var.environment
} 

# Добавляю глобальную метадату в виде ключей своего юзера
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "sgremyachikh:${file(var.public_key_path)}"
}
