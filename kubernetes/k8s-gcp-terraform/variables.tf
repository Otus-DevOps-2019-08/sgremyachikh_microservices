# ID проекта
variable project {
  description = "Project ID"
}
# region
variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zones {
  description = "zone"
  default     = "europe-west1-b"
}
variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}
variable "environment" {
  description = "environment type"
  default     = "microservices-docker"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable "cluster_name_suffix" {
  description = "A suffix to append to the default cluster name"
  default     = "kubernetes-3"
}

variable "network" {
  description = "The VPC network to host the cluster in"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
}

variable "compute_engine_service_account" {
  description = "Service account to associate to the nodes in the cluster"
}

variable "skip_provisioners" {
  type        = bool
  description = "Flag to skip local-exec provisioners"
  default     = false
}
# Для сервисного акка
variable "cluster_service_account_name" {
  description = "The name of the custom service account used for the GKE cluster. This parameter is limited to a maximum of 28 characters."
  type        = string
  default     = "example-cluster-sa"
}

variable "cluster_service_account_description" {
  description = "A description of the custom service account used for the GKE cluster."
  type        = string
  default     = "Example GKE Cluster Service Account managed by Terraform"
}
