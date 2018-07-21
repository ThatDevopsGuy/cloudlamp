resource "google_sql_database_instance" "master" {
  name             = "${var.cloudsql_instance}"
  database_version = "${var.cloudsql_db_version}"
  region           = "${var.gcp_region}"

  settings {
    tier = "${var.cloudsql_tier}"
  }
}

output "connection_name" {
  value = "${google_sql_database_instance.master.connection_name}"
}

resource "google_sql_user" "cloudsql-user" {
  name     = "${var.cloudsql_username}"
  instance = "${google_sql_database_instance.master.name}"
  password = "${var.master_password}"
}

resource "kubernetes_secret" "cloudsql-db-credentials" {
  metadata {
    name = "${var.cloudsql_db_credentials_name}"
  }

  data {
    username = "${var.cloudsql_username}"
    password = "${var.master_password}"
  }
}

resource "kubernetes_config_map" "dbconfig" {
  "metadata" {
    name = "dbconfig"
  }

  data = {
    dbconnection = "${google_sql_database_instance.master.connection_name}"
  }
}
