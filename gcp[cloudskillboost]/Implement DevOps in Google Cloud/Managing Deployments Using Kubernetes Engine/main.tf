#Create a cluster with five n1-standard-1 nodes
#gcloud container clusters create bootcamp --num-nodes 5 --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

resource "google_container_cluster" "gke-cluster" {
  name     = "bootcamp"
  location = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "bootcamp-pool"
  cluster    = google_container_cluster.gke-cluster.name
  node_count = 5
  location = "us-central1-a"
  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/projecthosting",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }
  depends_on = [google_container_cluster.gke-cluster]
}


resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = <<-EOT
    chmod +x script.sh
    ./script.sh
    EOT
  }
  depends_on =  [google_container_node_pool.primary_preemptible_nodes]
} 