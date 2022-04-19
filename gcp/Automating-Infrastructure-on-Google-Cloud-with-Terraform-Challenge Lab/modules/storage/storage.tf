resource "google_storage_bucket" "bucket" {
  name = "Bucket Name"
  location = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}
