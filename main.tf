# Create a Postgres VPC network
resource "google_compute_network" "postgres-vpc-network" {
  name                    = "postgres-vpc-network"
  auto_create_subnetworks = false
}



# Create a subnet within the VPC network
resource "google_compute_subnetwork" "postgres-subnet" {
  name          = "postgres-subnet"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.postgres-vpc-network.name
  region        = var.region
}

# Create firewall allowinng ssh access
resource "google_compute_firewall" "postgres-allow-ssh" {
  name    = "postgres-allow-ssh"
  network = google_compute_network.postgres-vpc-network.name

  allow {
    protocol = "all"
  }

  source_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
}


# Create a Compute Engine instance for the primary server
resource "google_compute_instance" "primary-postgres-instance" {
  name         = "primary-postgres-instance"
  machine_type = "n1-standard-1"
  zone         = var.primary_zone
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network    = google_compute_network.postgres-vpc-network.name
    subnetwork = google_compute_subnetwork.postgres-subnet.self_link
    access_config {}
  }

  metadata = {
    tags     = "allow-ssh"
    ssh-keys = "vadiraj:${file("id.pub")}"
  }

  metadata_startup_script = file("${path.module}/primary_startup.sh")

}

# Create a Compute Engine instance for the standby server
resource "google_compute_instance" "standby-postgres-instance" {
  name         = "standby-postgres-servere"
  machine_type = "n1-standard-1"
  zone         = var.primary_zone
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network    = google_compute_network.postgres-vpc-network.name
    subnetwork = google_compute_subnetwork.postgres-subnet.self_link
    access_config {}
  }

  metadata = {
    tags     = "allow-ssh"
    ssh-keys = "vadiraj:${file("id.pub")}"
  }



  #To configure replication local-exec is used to get primary and standby_public_ip to SSH Access for configuring replication
  provisioner "local-exec" {
    command = <<-EOT
    echo "${google_compute_instance.primary-postgres-instance.network_interface[0].access_config[0].nat_ip}" > ${path.module}/external_ip.txt;
    echo "${google_compute_instance.standby-postgres-instance.network_interface[0].access_config[0].nat_ip}" > ${path.module}/standby_ip.txt
  EOT
  }



  metadata_startup_script = file("${path.module}/standby_startup.sh")

}


#Creating a bucket to store the backup from standby-postgres-server to backup-target-bucket(expiry at 15 days)
resource "google_storage_bucket" "postgresbackup_bucket" {
  name     = "backup-target-bucket"
  location = var.region

  lifecycle_rule {
    condition {
      age = 15
    }
    action {
      type = "Delete"
    }
  }
}


#Setup an email alerting system:
resource "google_monitoring_notification_channel" "email-alerting" {
  display_name = "Email Channel"
  type         = "email"
  labels = {
    email_address = "toggltrack@toggl.com"
  }
}



#Alerting Setup for CPU and Disk Utilization
resource "google_monitoring_alert_policy" "cpu-alert-policy" {
  display_name = "High-CPU-Utilization-Policy"
  combiner     = "OR"

  conditions {
    display_name = "High-CPU-Utilization-Policy"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.95
    }
  }

}

resource "google_monitoring_alert_policy" "disk-alert-policy" {
  display_name = "High-Disk-Utilization-Policy"
  combiner     = "OR"

  conditions {
    display_name = "High-Disk-Utilization-Policyc"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\" AND resource.type=\"gce_instance\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 85
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

