#create VPC with single subnet
resource "google_compute_network" "lab-vpc" {
  name                    = "securenetwork"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "lab-subnet" {
  name        = "lab-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.lab-vpc.self_link
  depends_on = [google_compute_network.lab-vpc]
}


#create cloud firewall, allow port 3389 inbound for bastion host
resource "google_compute_firewall" "bastion-firewall" {
  name    = "bastion-firewall"
  network = google_compute_network.lab-vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["bastion-host"]
  depends_on = [google_compute_network.lab-vpc]
}

#compute instances

#bastion instance configuration:
resource "google_compute_instance" "bastion-host" {
  name = "vm-bastionhost"
  machine_type = "n1-standard-1"
  zone = var.zone
  boot_disk {
  initialize_params {
    image = "windows-server-2016-dc-v20220414"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.lab-subnet.self_link
    access_config {
    }
  }
  network_interface {
   network = var.default-network
  }
  tags = ["bastion-host"]
  depends_on = [google_compute_firewall.bastion-firewall]
}

#secure instance configuration:
resource "google_compute_instance" "secure-instance" {
  name =  "vm-securehost" 
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "windows-server-2016-dc-v20220414"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.lab-subnet.self_link
  }
  network_interface {
    network = var.default-network
  }
  tags = ["secure-host"]   
  depends_on = [google_compute_network.lab-vpc]         
}

