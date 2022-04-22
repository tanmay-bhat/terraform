#create cloud repository
resource "google_sourcerepo_repository" "REPO_DEMO" {
  name = "REPO_DEMO"
}

resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = <<-EOT
    chmod +x script.sh
    ./script.sh
    EOT
  }
  depends_on =[google_sourcerepo_repository.REPO_DEMO]
} 