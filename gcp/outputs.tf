output "node_pubips" {
  description = "A list of the pub IP addresses for all 3 nodes."
  value       = google_compute_instance.Node[*].network_interface[0].access_config[0].nat_ip
}

output "node_privips" {
  description = "A list of the priv IP addresses for all 3 nodes."
  value       = google_compute_instance.Node[*].network_interface[0].network_ip
}
