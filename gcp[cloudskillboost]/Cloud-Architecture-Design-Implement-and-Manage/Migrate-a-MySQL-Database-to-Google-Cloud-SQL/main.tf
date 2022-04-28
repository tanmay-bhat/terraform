#Create a cloud SQL DB instance
resource "google_sql_database_instance" "wordpress-db" {
  name             = "wordpress-instance"
  database_version = "MYSQL_5_7"
  region           = var.region
  deletion_protection = false
  
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
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


