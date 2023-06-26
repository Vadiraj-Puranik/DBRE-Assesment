output "primary_server_ip" {
  value = google_compute_instance.primary-postgres-instance.network_interface.0.network_ip
}

output "standby_ip" {
  value = google_compute_instance.standby-postgres-instance.network_interface.0.network_ip
}

output "standby_public_ip" {
  value = google_compute_instance.standby-postgres-instance.network_interface[0].access_config[0].nat_ip
}

output "primary_public_ip" {
  value = google_compute_instance.primary-postgres-instance.network_interface[0].access_config[0].nat_ip
}