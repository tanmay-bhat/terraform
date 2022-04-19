terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.18.0"
    }
  }
  # backend "gcs" {
  #   bucket  = module.storage.name
  #   prefix  = "terraform/state"
  #   }
}

provider "google" {
    project = var.project-id
    region  = var.region
}

# modules section

module "instances" {
  source = "./modules/instances"
}

# module "storage" {
#   source = "./modules/storage"
# }

module "vpc" {
    source  = "terraform-google-modules/network/google//modules/vpc"
    version = "~> 2.0.0"
    project_id   = var.project_id
    network_name = "VPC Name"
    routing_mode = "GLOBAL"
    shared_vpc_host = false
}

module "subnets" {
    source  = "terraform-google-modules/network/google//modules/subnets"
    version = "~> 2.0.0"

    project_id   = var.project_id
    network_name = module.vpc.network_name

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "us-central1"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-west1"
        }
    ]

}

#firewall 
resource "google_compute_firewall" "tf-firewall" {
  name    = "tf-firewall"
  network = module.vpc.network_name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

}

