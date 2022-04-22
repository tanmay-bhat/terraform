resource "google_compute_instance" "tf-instance-1" {
  name =  "tf-instance-1" 
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
}
  network_interface {
    network = "default"
    # network = "VPC Name"
    # subnetwork = tolist(module.subnets.subnet_name)[1]
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true

}

resource "google_compute_instance" "tf-instance-2" {
  name =  "tf-instance-2" 
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
}
  network_interface {
    network = "default"
    # network = "VPC Name"
    # subnetwork = tolist(module.subnets.subnet_name)[1]
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true

}

resource "google_compute_instance" "tf-instance-813516" {
  name =  "tf-instance-813516" 
  machine_type = "n1-standard-2"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
}
  network_interface {
    network = "default"
    # network = "VPC Name"
    # subnetwork = tolist(module.subnets.subnet_name)[1]
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true

}