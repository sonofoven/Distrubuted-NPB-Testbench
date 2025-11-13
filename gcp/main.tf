provider "google" {
  project = "distributed-npb-testbench"
  region  = "us-west2"
  zone    = "us-west2-b"
}

resource "google_compute_network" "vpc_network" {
  name = "npb-cluster-network"
}

resource "google_compute_instance" "Node1" {
  name         = "npb-test-1"
  machine_type = "e2-standard-4"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}
