#references : 
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_http_health_check
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy
#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule

#Task 1 
#configs for 3 webservers
resource "google_compute_instance" "web-server-1" {
  name         = "www1"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  network_interface {
        network = "default"
    }       
  tags         = ["network-lb-tag"]
  metadata = {
    startup-script = "#! /bin/bash
      sudo apt-get update
      sudo apt-get install apache2 -y
      sudo service apache2 restart
      echo '<!doctype html><html><body><h1>www1</h1></body></html>' | tee /var/www/html/index.html"
  }
}


resource "google_compute_instance" "web-server-2" {
  name         = "www2"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    } 
  network_interface {
        network = "default"
    }      
  tags         = ["network-lb-tag"]
  metadata = {
    startup-script = "#! /bin/bash
      sudo apt-get update
      sudo apt-get install apache2 -y
      sudo service apache2 restart
      echo '<!doctype html><html><body><h1>www2</h1></body></html>' | tee /var/www/html/index.html"
  }
}


resource "google_compute_instance" "web-server-3" {
  name         = "www3"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    } 
  network_interface {
        network = "default"
    }      
  tags         = ["network-lb-tag"]
  metadata = {
    startup-script = "#! /bin/bash
      sudo apt-get update
      sudo apt-get install apache2 -y
      sudo service apache2 restart
      echo '<!doctype html><html><body><h1>www3</h1></body></html>' | tee /var/www/html/index.html"
  }
}

#create the firewall rule for the attaching to the above instances via tag

resource "google_compute_firewall" "allow-http" {
  name          = "www-firewall-network-lb"
  description   = "Allow HTTP traffic"
  network       = "default"
  target_tags   = ["network-lb-tag"]
    allow {
        protocol = "tcp"
        ports    = ["80"]
    }


# Task2

#create a static IP
resource "google_compute_address" "network-lb-ip-1" {
  name = "www-ip"
  region = "us-central1"
}

#http health check resource
resource "google_compute_http_health_check" "default" {
    name = "basic-check"
    request_path = "/"
}

#create a target pool & attach the webservers to it
resource "google_compute_target_pool" "www-lb" {
  name        = "www-pool"
  region = "us-central1"
  http_health_check = google_compute_http_health_check.default.self_link
  instances = [google_compute_instance.web-server-1.self_link, google_compute_instance.web-server-2.self_link, google_compute_instance.web-server-3.self_link]
}

#creat a forwarding rule
resource "google_compute_forwarding_rule" "www-lb" {
  name = "www-rule"
  region = "us-central1"
  ip_address = google_compute_address.network-lb-ip-1.address
  target = google_compute_target_pool.www-lb.self_link
  port_range = "80"
}

#Task 3
#Create a instance template for the creation of web servers

resource "google_compute_instance_template" "lb-backend-template" {
    name = "lb-backend-template"
    machine_type = "n1-standard-1"
    zone = "us-central1-a"
    network = "default"
    subnetwork = "default"
    tags = ["allow-health-check"]
    disk {
        source_image = "debian-cloud/debian-9"
        auto_delete = true
        boot = true
    }
    network_interface {
        network = "default"
    }
    metadata = {
        startup-script = "#! /bin/bash
        apt-get update
        apt-get install apache2 -y
        a2ensite default-ssl
        a2enmod ssl
        vm_hostname="$(curl -H "Metadata-Flavor:Google" \
        http://169.254.169.254/computeMetadata/v1/instance/name)"
        echo "Page served from: $vm_hostname" | \
        tee /var/www/html/index.html
        systemctl restart apache2'
}

#Create managed instance group using the above created instance template

resource "google_compute_instance_group_manager" "lb-backend-group" {
    name = "lb-backend-group"
    instance_template = google_compute_instance_template.lb-backend-template.self_link
    zone = "us-central1-a"
    target_size = 2
}

#Create firewall rule for the instance group

resource "google_compute_firewall" "allow-health-check" {
    name = "allow-health-check"
    description = "Allow health check"
    network = "default"
    source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
    target_tags = ["allow-health-check"]
    port_range = "80"

#Create a static IP for the LB 

resource "google_compute_global_address" "network-lb-ip-2" {
    name = "lb-ipv4-1"
    region = "us-central1"
    network = "default"
    ip_version = "IPV4"
}

#Create a health check for the load balancer
resource "google_compute_health_check" "http-basic-check" {
    name = "http-basic-check"
    tcp_health_check {
        port = "80"
    }
}


#Create a backend service for the load balancer
resource "google_compute_backend_service" "web-backend-service" {
    zone = "us-central1-a"
    name = "web-backend-service"
    health_checks = [google_compute_health_check.http-basic-check.self_link]
    protocol = "HTTP"
    port_name = "http"
    backend {
        group = google_compute_instance_group_manager.lb-backend-group.self_link
    }
}

#Create a URL map to route the incoming requests to the default backend service:
resource "google_compute_url_map" "web-map-http" {
    name = "web-map-http"
    default_service = google_compute_backend_service.web-backend-service.self_link
}

#Create a target HTTP proxy to route requests to your URL map:
resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.web-map-http.self_link
}

#Create a global forwarding rule to route incoming requests to the proxy:
resource "google_compute_forwarding_rule" "http-content-rule" {
  name                  = "http-content-rule"
  region                = "us-central1"
  ip_address            = google_compute_global_address.network-lb-ip-2.address
  target                = google_compute_target_http_proxy.http-lb-proxy.self_link
  port_range            = "80"

}
