# Note: This file is generated from preflight.sh:
terraform {
 backend "gcs" {
   bucket  = "tdg-cloudlamp-5-cloudlamp-terraform"
   prefix  = "/tf/terraform.tfstate"
   project = "tdg-cloudlamp-5"
 }
}
