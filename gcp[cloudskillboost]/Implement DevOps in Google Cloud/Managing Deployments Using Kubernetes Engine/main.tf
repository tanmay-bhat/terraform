resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = <<-EOT
    chmod +x script.sh
    ./script.sh
    EOT
  }
}

#Create a cluster with five n1-standard-1 nodes
#gcloud container clusters create bootcamp --num-nodes 5 --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

resource "google_container_cluster" "gke-cluster" {
  name     = "bootcamp"
  location = "us-central1"
  remove_default_node_pool = true
  initial_node_count       = 1
  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/projecthosting,storage-rw"
    ]
  }
}
