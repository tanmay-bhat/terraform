#Create a cluster with five n1-standard-1 nodes
#gcloud container clusters create jenkins-cd \
# --num-nodes 2 \
# --machine-type n1-standard-2 \
# --scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform"

resource "google_container_cluster" "jenkins-cluster" {
  name     = "jenkins-cd"
  location = "us-east1-d"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "jenkins-pool"
  cluster    = google_container_cluster.jenkins-cluster.name
  node_count = 2
  location = "us-east1-d"
  node_config {
    preemptible  = true
    machine_type = "n1-standard-2"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/source.read_write",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  depends_on = [google_container_cluster.jenkins-cluster]
}

#create cloud repository
resource "google_sourcerepo_repository" "default-repo" {
  name = "default"
}

# resource "null_resource" "git_clone" {
#   provisioner "local-exec" {
#     command = <<-EOT
#     chmod +x script.sh
#     ./script.sh
#     EOT
#   }
#   depends_on =  [google_container_node_pool.primary_preemptible_nodes]
# } 