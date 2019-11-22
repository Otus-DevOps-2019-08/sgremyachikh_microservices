# ID проекта
variable project {
  description = "Project ID"
}
# region
variable region {
  description = "Region"
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
