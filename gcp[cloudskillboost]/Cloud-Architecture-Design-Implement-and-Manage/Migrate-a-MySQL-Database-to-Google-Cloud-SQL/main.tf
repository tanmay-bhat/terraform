#Create a cloud SQL DB instance
resource "google_sql_database_instance" "wordpress-db" {
  name             = "wordpress-instance"
  database_version = "MYSQL_5_7"
  region           = var.region
  deletion_protection = false
  
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }    
  }
}


resource "google_sql_database" "wordpress-database" {
  name     = "wordpress"
  instance = google_sql_database_instance.wordpress-db.name
  depends_on = [google_sql_database_instance.wordpress-db]
}


resource "google_sql_user" "users" {
  name     = "blogadmin"
  instance = google_sql_database_instance.wordpress-db.name
  password = "Password1*"
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


