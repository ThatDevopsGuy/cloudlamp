# CloudLAMP Terraform Files
# Copyright 2018, Google LLC
# Fernando Sanchez <fersanchez@google.com>
# Sebastian Weigand <tdg@google.com>

provider "google" {
  region  = "${var.gcp_region}"
  project = "${var.gcp_project}"
}

provider "kubernetes" {
  host     = "${google_container_cluster.primary.endpoint}"
  username = "${var.gke_username}"
  password = "${var.master_password}"

  client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}
