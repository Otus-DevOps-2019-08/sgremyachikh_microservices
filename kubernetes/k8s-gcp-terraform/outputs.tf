output "kubernetes_endpoint" {
  sensitive = false
  value     = module.gke.endpoint
}

output "client_token" {
  sensitive = false
  value     = base64encode(data.google_client_config.default.access_token)
}

output "ca_certificate" {
  value = module.gke.ca_certificate
}

output "service_account" {
  description = "The default service account used for running nodes."
  value       = module.gke.service_account
}
