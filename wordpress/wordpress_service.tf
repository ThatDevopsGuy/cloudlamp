# CloudLAMP Terraform Files
# Copyright 2018, Google LLC
# Fernando Sanchez <fersanchez@google.com>
# Sebastian Weigand <tdg@google.com>

resource "kubernetes_replication_controller" "cloud-drupal" {
  metadata {
    name = "${var.gke_service_name}-repl-ctrlr"
  }

  spec {
    selector {
      app = "${var.gke_app_name}"
    }

    replicas = 1

    template {
      volume {
        name = "${var.vol_1}"

        persistent_volume_claim {
          claim_name = "${var.vol_1}-claim"
        }
      }

      volume {
        name = "${var.cloudsql_instance_credentials_name}"

        secret {
          secret_name = "${var.cloudsql_instance_credentials_name}"
        }
      }

      volume {
        name = "${var.cloudsql_db_credentials_name}"

        secret {
          secret_name = "${var.cloudsql_db_credentials_name}"
        }
      }

      container {
        image = "${var.gke_wordpress_image}"
        name  = "wordpress"

        env = [
          {
            name = "WORDPRESS_DB_PASSWORD"

            value_from = {
              secret_key_ref = {
                name = "${var.cloudsql_db_credentials_name}"
                key  = "password"
              }
            }
          },
          {
            name = "WORDPRESS_DB_USER"

            value_from = {
              secret_key_ref = {
                name = "${var.cloudsql_db_credentials_name}"
                key  = "username"
              }
            }
          },
          {
            name  = "WORDPRESS_DB_HOST"
            value = "127.0.0.1:3306"
          },
        ]

        volume_mount {
          name       = "${var.vol_1}"
          mount_path = "/var/www/html"
        }
      }

      container {
        image = "${var.gke_cloudsql_image}"
        name  = "cloudsql-proxy"

        command = [
          "/cloud_sql_proxy",
          "-instances=${google_sql_database_instance.master.connection_name}=tcp:3306",
          "-credential_file=/secrets/${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}/credentials.json",
        ]

        volume_mount {
          name       = "${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
          mount_path = "/secrets/${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
          read_only  = true
        }
      }
    }
  }
}

resource "kubernetes_service" "cloud-wordpress" {
  metadata {
    name = "${var.gke_service_name}"
  }

  spec {
    selector {
      app = "${var.gke_app_name}"
    }

    type = "LoadBalancer"

    // not working:
    //load_balancer_ip = "${google_compute_address.frontend.0.address}"

    session_affinity = "ClientIP"
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }
}

output "lb_ip" {
  value = "${kubernetes_service.cloud-wordpress.load_balancer_ingress.0.ip}"
}
