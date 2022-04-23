
#create the bucket
resource "google_storage_bucket" "script-bucket" {
  name = "startup-script"
  location = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

#create the object inside the above created bucket
resource "google_storage_bucket_object" "startup-script" {
  name   = "startup-script"
  source = "./install-web.sh"
  bucket = google_storage_bucket.script-bucket
  depends_on = [google_storage_bucket.script-bucket]
}


#create a compute instance and configure it to use the startup-script from above cloud bucket
resource "google_compute_instance" "demo-instance" {
  name =  "demo-instance" 
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
}
  network_interface {
    network = "default"
  }
  metadata = {
    startup-script-url = "gs:///${google_storage_bucket.script-bucket.name}/${google_storage_bucket_object.startup-script.name}"
  }
  tags = [ "demo" ]
  depends_on = [google_storage_bucket_object.startup-script]
}

#create cloud firewall
resource "google_compute_firewall" "demo-firewall" {
  name    = "demo-firewall"
  network = google_compute_network.default.name

  allow {
    protocol = "http"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["demo"]
}