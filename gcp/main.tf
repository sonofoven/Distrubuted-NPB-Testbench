provider "google" {
  project = "distributed-npb-testbench"
  region  = "us-west2"
  zone    = "us-west2-b"
}

data "local_file" "ssh_key" {
  filename = "${path.module}/../ansible/keys/${var.ssh_key_name}"
}

resource "google_compute_project_metadata" "ssh_key-metadata" {
  metadata = {
    ssh-keys = "${var.ssh_user}:${data.local_file.ssh_key.content}"
  }
}

resource "google_compute_network" "vpc_network" {
  name = "npb-cluster-network"
}

resource "google_compute_firewall" "allow_ssh_ingress" {
  name    = "allow-ssh-to-nodes"
  network = google_compute_network.vpc_network.name

  target_tags = ["allow-ssh"]

  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow_icmp_ingress" {
  name    = "allow-icmp-to-nodes"
  network = google_compute_network.vpc_network.name

  target_tags = ["allow-icmp"]

  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_all_internal" {
  name    = "allow-all-internal-npb"
  network = google_compute_network.vpc_network.name

  target_tags = ["allow-internal"]

  direction = "INGRESS"

  source_ranges = ["10.0.0.0/8"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_instance" "Node" {
  count        = 3
  name         = "npb-test-${count.index + 1}"
  machine_type = var.instance_type

  tags = ["allow-ssh", "allow-icmp", "allow-internal"]

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
