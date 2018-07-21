resource "google_container_cluster" "primary" {
  name = "${var.gke_cluster_name}"
  zone = "${var.gcp_zone}"

  node_pool {
    name               = "${var.gke_cluster_name}-pool"
    initial_node_count = "${var.gke_cluster_size}"

    node_config {
      machine_type = "${var.gke_machine_type}"
    }

    autoscaling {
      min_node_count = "${var.gke_cluster_size}"
      max_node_count = "${var.gke_max_cluster_size}"
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  master_auth {
    username = "${var.gke_username}"
    password = "${var.master_password}"
  }

  enable_legacy_abac = true
}
