#Create a cluster with 2 n1-standard-2 nodes

resource "google_container_cluster" "gke-cluster" {
  name     = "echo-cluster"
  location = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "echo-cluster-pool"
  cluster    = google_container_cluster.gke-cluster.name
  node_count = 2
  location = "us-central1-a"
  node_config {
    preemptible  = true
    machine_type = "n1-standard-2"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/projecthosting",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }
  depends_on = [google_container_cluster.gke-cluster]
}


resource "null_resource" "script" {
  provisioner "local-exec" {
    command = <<-EOT
    chmod +x script.sh
    ./script.sh
    EOT
  }
  depends_on =  [google_container_node_pool.primary_preemptible_nodes]
} 