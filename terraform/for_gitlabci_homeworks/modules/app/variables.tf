variable zone {
  description = "instance creation zone"
  default     = "europe-west1-b"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
  default = "~/.ssh/id_rsa.pub"
}
variable connection_key {
  description = "private key for provisioners connection"
  default = "~/.ssh/id_rsa"
}

variable machine_type {
  description = "type of instance"
  default     = "g1-small"
}

variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}
variable "environment" {
  description = "environment type"  
}
