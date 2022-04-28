#create the bucket
resource "google_storage_bucket" "script-bucket" {
  name = "${var.project_id}-startup-script"
  location = "US"
  force_destroy = true
}

#create the object i.e shell script inside the above created bucket
resource "google_storage_bucket_object" "startup-script" {
  name   = "install-web.sh"
  source = "./install-web.sh"
  bucket = google_storage_bucket.script-bucket.name
  depends_on = [google_storage_bucket.script-bucket]
}

#provide read-only public access to the shell script
resource "google_storage_object_access_control" "public_rule" {
  object = google_storage_bucket_object.startup-script.name
  bucket = google_storage_bucket.script-bucket.name
  role   = "READER"
  entity = "allUsers"
  depends_on = [google_storage_bucket_object.startup-script]
}

#create VPC, its needed for fireweall rules. If you want to create in default vpc only, then import default-vpc into terraform and use it.
resource "google_compute_network" "demo-vpc" {
  name                    = "demo-vpc"
}


#create a compute instance and configure it to use the startup-script from above cloud bucket
resource "google_compute_instance" "demo-instance" {
  name =  "demo-instance" 
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
}
  network_interface {
    network = "${google_compute_network.demo-vpc.self_link}"
    access_config {}
  }
  metadata = {
    startup-script-url = "https://storage.googleapis.com/${google_storage_bucket.script-bucket.name}/${google_storage_bucket_object.startup-script.name}"
  }
  tags = ["demo"]
  service_account {
  # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles. But since its Lab, you can assign roles to custom SA.
  email  = "65342497920-compute@developer.gserviceaccount.com"
  scopes = ["cloud-platform"]
  }    
  depends_on = [google_storage_bucket_object.startup-script,
              google_compute_network.demo-vpc]         
}

#create cloud firewall, allow port 80 and 22
resource "google_compute_firewall" "demo-firewall" {
  name    = "demo-firewall"
  network = "${google_compute_network.demo-vpc.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["demo"]
  depends_on = [google_compute_instance.demo-instance,
                google_compute_network.demo-vpc]
}

