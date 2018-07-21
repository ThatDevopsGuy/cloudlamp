# CloudLAMP Terraform Variables

# These are populated from your gcloud config, from preflight.sh:

variable "gcp_project" {}
variable "gcp_region" {}
variable "gcp_zone" {}

variable "master_password" {
  default = "cloudlampcloudlamp"
}

# =============================================================================
# NFS
# =============================================================================

variable "nfs_server_name" {
  default = "cloudlamp-nfs-server"
}

variable "nfs_server_os_image" {
  # Debian Stretch has an annoying bug in NFS server post-install, which Ubuntu does not:
  default = "ubuntu-1804-bionic-v20180717b"
}

variable "nfs_disk_name" {
  default = "cloudlamp-nfs-disk"
}

variable "export_path" {
  default = "/srv/nfs"
}

variable "nfs_machine_type" {
  default = "n1-standard-2"
}

variable "nfs_raw_disk_type" {
  default = "pd-standard"
}

variable "vol_1" {
  default = "wordpress-vol"
}

variable "vol_1_size" {
  default = "200Gi"
}

variable "gke_nfs_mount_path" {
  default = "/var/www/html/"
}

# =============================================================================
# CloudSQL
# =============================================================================

variable "cloudsql_service_account_name" {
  default = "cloudsql-service-account-1"
}

variable "cloudsql_client_role" {
  default = "roles/cloudsql.client"
}

variable "create_keys_role" {
  default = "roles/iam.serviceAccountKeyAdmin"
}

variable "cloudsql_instance" {
  default = "cloudlamp-sql"
}

variable "cloudsql_username" {
  default = "cloudlamp-user"
}

variable "cloudsql_tier" {
  default = "db-n1-standard-1"
}

variable "cloudsql_db_version" {
  default = "MYSQL_5_7"
}

variable "cloudsql_db_credentials_name" {
  default = "cloudsql-db-credentials"
}

variable "cloudsql_instance_credentials_name" {
  default = "cloudsql-instance-credentials"
}

# =============================================================================
# GKE
# =============================================================================

variable "gke_cluster_name" {
  default = "cloudlamp-gke-cluster"
}

variable "gke_cluster_size" {
  default = 3
}

variable "gke_machine_type" {
  default = "n1-standard-2"
}

variable "gke_max_cluster_size" {
  default = 10
}

variable "gke_username" {
  default = "cloudlamp-gke-client"
}

# =============================================================================
# Wordpress
# =============================================================================

variable "gke_service_name" {
  default = "cloudlamp-wordpress-service"
}

variable "gke_app_name" {
  default = "cloudlamp-wordpress-app"
}

variable "gke_wordpress_image" {
  default = "wordpress:latest"
}

variable "gke_cloudsql_image" {
  default = "gcr.io/cloudsql-docker/gce-proxy:latest"
}
