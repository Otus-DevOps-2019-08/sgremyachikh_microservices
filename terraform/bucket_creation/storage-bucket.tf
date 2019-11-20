provider "google" {
  version = "~> 2.15"
  project = var.project
  region  = var.region
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.0"

  # Имя поменяйте на другое
  name = "storage-bucket-sgremyachikh-for-docker"
  location = var.region
}

output storage-bucket_url {
  value = module.storage-bucket.url
}

