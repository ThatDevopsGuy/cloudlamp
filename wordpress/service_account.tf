
# CloudLAMP Terraform Files
# Copyright 2018, Google LLC
# Fernando Sanchez <fersanchez@google.com>
# Sebastian Weigand <tdg@google.com>


resource "google_service_account" "cloudsql-sa" {
  account_id   = "${var.cloudsql_service_account_name}"
  display_name = "CloudSQL service account"
}

data "google_iam_policy" "cloudsql-client-plus-create-keys" {
  binding {
    role = "${var.cloudsql_client_role}"

    members = [
      "serviceAccount:${google_service_account.cloudsql-sa.email}",
    ]
  }

  binding {
    role = "${var.create_keys_role}"

    members = [
      "serviceAccount:${google_service_account.cloudsql-sa.email}",
    ]
  }
}

resource "google_project_iam_policy" "cloudsql-client-plus-create-keys-on-project" {
  project     = "${var.gcp_project}"
  policy_data = "${data.google_iam_policy.cloudsql-client-plus-create-keys.policy_data}"
}

resource "google_service_account_key" "cloudsql-sa-key" {
  service_account_id = "${google_service_account.cloudsql-sa.email}"
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "kubernetes_secret" "cloudsql-instance-credentials" {
  metadata {
    name = "${var.cloudsql_instance_credentials_name}"
  }

  data {
    credentials.json = "${base64decode(google_service_account_key.cloudsql-sa-key.private_key)}"
  }
}
