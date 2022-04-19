resource "google_compute_instance" "tf-instance-1" {
  machine_type = 
  boot_disk = 
  network_interface = {
    network = "default"
    # network = "VPC Name"
    subnetwork = tolist(module.subnets.subnet_name)[1]
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true

}

resource "google_compute_instance" "tf-instance-2" {
  machine_type = 
  boot_disk = 
  network_interface = {
    network = "default"
    subnetwork = tolist(module.subnets.subnet_name)[1]
    # network = "VPC Name"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true

}

# resource "google_compute_instance" "Instance Name" {
#   machine_type = 
#   boot_disk = 
#   network_interface = {
#     network = default
#   }
#   metadata_startup_script = <<-EOT
#         #!/bin/bash
#     EOT
#   allow_stopping_for_update = true

# }