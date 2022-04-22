#enable the Cloud Scheduler API
resource "google_project_service" "cloud-Scheduler-api" {
  project = var.project-id
  service = "cloudscheduler.googleapis.com"
}

#create required (2n) compute disks
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

# create compute instance & attach the create disk to it
resource "google_compute_instance" "disk-instance" {
    name = var.instance-name
    zone = "us-central1-a"
    machine_type = "n1-standard-1"
    boot_disk {
        initialize_params {
        image = "debian-cloud/debian-9"
        }
    }

#comment out lines 43-> 46 to detach the disk from VM    
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

#execute shell script to clone the GCP repo, replce project ID with current ID
resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = <<-EOT
    "chmod +x script.sh"
    "./script.sh"
    EOT
  }
} 

# Compress source code cloned earlier
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "gcf-automated-resource-cleanup/unattached-pd"
  output_path = "gcf-automated-resource-cleanup/unattached-pd.zip"
  depends_on = [null_resource.git_clone]
}


# Create a cloud bucket that will host the source code
resource "google_storage_bucket" "bucket" {
  name = "delete-pd-function-${var.project-id}"
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
  depends_on = [google_storage_bucket.bucket]
}

#create app engine
resource "google_app_engine_application" "app-engine" {
  project     = var.project-id
  location_id = var.app-location
  depends_on = [google_cloudfunctions_function.delete-pd-function] 
}

#create scheduler job to run function at 2 AM every night
resource "google_cloud_scheduler_job" "job" {
  name        = "unattached-pd-job"
  schedule    = "* 2 * * *"
    http_target {
      uri = google_cloudfunctions_function.delete-pd-function.https_trigger_url
    }
  depends_on = [google_cloudfunctions_function.delete-pd-function]  
}