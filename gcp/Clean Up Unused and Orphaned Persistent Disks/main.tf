#enable the Cloud Scheduler API

resource "google_project_service" "cloud-Scheduler-api" {
  project = var.project-id
  service = "cloudscheduler.googleapis.com"
}

#create compute disks

resource "google_compute_disk" "orphaned-disk" {
  name  = var.orphaned-disk
  type  = "pd-ssd"
  zone  = "us-central1-a"
  size = "200"
  labels = {
    environment = "demo"
  }
}

resource "google_compute_disk" "unused-disk" {
  name  = var.unused-disk
  type  = "pd-ssd"
  zone  = "us-central1-a"
  size = "250"
  labels = {
    environment = "demo"
  }
}

# create compute instance

resource "google_compute_instance" "disk-instance" {
    name = var.instance-name
    zone = "us-central1-a"
    machine_type = "n1-standard-1"
    boot_disk {
        initialize_params {
        image = "debian-cloud/debian-9"
        }
    }

#comment out lines 42-> 46 to detach the disk from VM    
    attached_disk {
      source = google_compute_disk.orphaned-disk.self_link
      device_name = google_compute_disk.orphaned-disk.name
      mode = "READ_WRITE"
    }

  network_interface {
    network = "default"
  }
    depends_on = [google_compute_disk.orphaned-disk]
}

resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = "../scripts/script.sh"
    interpreter = ["bash"]
  }
}


# Compress source code
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "gcf-automated-resource-cleanup/unattached-pd"
  output_path = "gcf-automated-resource-cleanup/unattached-pd.zip"
}


# Create bucket that will host the source code
resource "google_storage_bucket" "bucket" {
  name = "delete-pd-function"
  location = "us-central1"
}

# Add source code zip to bucket
resource "google_storage_bucket_object" "zip" {
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.source.output_path
  name   = "source.zip#${data.archive_file.source.output_md5}"
  depends_on = [google_storage_bucket.bucket]
}

# create cloud function 

resource "google_cloudfunctions_function" "delete-pd-function" {
  name        = "delete_unattached_pds"
  runtime     = "python39"

  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.zip.name
  trigger_http          = true
  entry_point           = "delete_unattached_pds"
}