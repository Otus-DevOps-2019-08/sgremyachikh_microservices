terraform {
# ---------------------------------------------------------------------------------------------------------------------
# Версия terraform
# ---------------------------------------------------------------------------------------------------------------------
  required_version        = "~>0.12.0"
}

# 
locals {
  cluster_type            = "simple-autoscale"
}
# ---------------------------------------------------------------------------------------------------------------------
# version was uped to 3.3.0 for module "gke"
# ---------------------------------------------------------------------------------------------------------------------
provider "google" {
  # Версия провайдера
  version                 = "~> 3.3.0"
  # ID проекта
  project                 = var.project
  # регион развертывания
  region                  = var.region
}
# ---------------------------------------------------------------------------------------------------------------------
#taken from https://github.com/terraform-google-modules/terraform-google-kubernetes-engine
# ---------------------------------------------------------------------------------------------------------------------
module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  project_id             = var.project
  name                   = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  regional               = false
#  region                 = var.region
  network                = var.network
  subnetwork             = var.subnetwork
  ip_range_pods          = var.ip_range_pods
  ip_range_services      = var.ip_range_services
  zones                  = [var.zones]
  http_load_balancing    = true
#  create_service_account = false
#  service_account        = var.compute_engine_service_account
  skip_provisioners      = var.skip_provisioners

  node_pools = [
    {
      name               = "cluster-node-pool"
      machine_type       = "n1-standard-1"
      disk_size_gb       = 10
      autoscaling        = true
      auto_repair        = true
      auto_upgrade       = true
      min_count          = 2
      max_count          = 3
      initial_node_count = 2
    },
#    {
#      name               = "elastic-node-pool"
#      machine_type       = "n1-standard-2"
#      autoscaling        = true
#      auto_repair        = true
#      auto_upgrade       = true
#      min_count          = 1
#      max_count          = 2
#      disk_size_gb       = 20
#      preemptible        = false
#      initial_node_count = 1
#    }
  ]

  node_pools_labels = {
    elastic-node-pool = {elastichost=true}

    default-node-pool = {
      default-node-pool = true
    }
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# also from https://github.com/terraform-google-modules/terraform-google-kubernetes-engine
# ---------------------------------------------------------------------------------------------------------------------
data "google_client_config" "default" {
}
# ---------------------------------------------------------------------------------------------------------------------
# модуль для доступа ко всем ВМ по 22 порту ssh
# ---------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source                  = "./modules/vpc"
  source_ranges           = var.source_ranges
  environment             = var.environment
} 

#  32092
resource "google_compute_firewall" "firewall" {
  name                    = "allow-for-kubernetes"
  network                 = "default"
  allow {
    protocol              = "tcp"
    ports                 = ["80"]
  }
  source_ranges           = ["0.0.0.0/0"]
}
# ---------------------------------------------------------------------------------------------------------------------
# Добавляю глобальную метадату в виде ключей своего юзера
# ---------------------------------------------------------------------------------------------------------------------
resource "google_compute_project_metadata_item" "ssh-keys" {
  key                     = "ssh-keys"
  value                   = "sgremyachikh:${file(var.public_key_path)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CUSTOM SERVICE ACCOUNT TO USE WITH THE GKE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "gke_service_account" {
# ---------------------------------------------------------------------------------------------------------------------
# When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
# to a specific version of the modules, such as the following example:
# source = "github.com/gruntwork-io/terraform-google-gke.git//modules/gke-service-account?ref=v0.2.0"
# ---------------------------------------------------------------------------------------------------------------------
  source = "./modules/gke-service-account"

  name        = var.cluster_service_account_name
  project     = var.project
  description = var.cluster_service_account_description
}
