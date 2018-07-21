#!/usr/bin/env bash
# CloudLAMP Pre-flight script
# Copyright 2018 Google, LLC
# Sebastian Weigand <tdg@google.com>
# Fernando Sanchez <fersanchez@google.com>

echo "
  _______             ____   ___   __  ______
 / ___/ /__  __ _____/ / /  / _ | /  |/  / _ \\
/ /__/ / _ \/ // / _  / /__/ __ |/ /|_/ / ___/
\___/_/\___/\_,_/\_,_/____/_/ |_/_/  /_/_/
"
echo "Welcome to CloudLAMP!"

# =============================================================================
# Functions
# =============================================================================

# Prefixes output and writes to STDERR:
error() {
	echo -e "\n\nCloudLAMP Error: $@\n" >&2
}

# Checks for command presence in $PATH, errors:
check_command() {
	TESTCOMMAND=$1
	HELPTEXT=$2

	printf '%-50s' " - $TESTCOMMAND..."
	command -v $TESTCOMMAND >/dev/null 2>&1 || {
		echo "[ MISSING ]"
		error "The '$TESTCOMMAND' command was not found. $HELPTEXT"

		exit 1
	}
	echo "[ OK ]"
}

# Tests variables for valid values:
check_config() {
	PARAM=$1
	VAR=$2
	printf '%-50s' " - '$VAR'..."
	if [[ $PARAM == *"(unset)"* ]]; then
		echo "[ UNSET ]"
		error "Please set the gcloud variable '$VAR' via:
		gcloud config set $VAR <value>"

		exit 1
	fi
	echo "[ OK ]"
}

# Returns just the value we're looking for OR unset:
gcloud_activeconfig_intercept() {
	gcloud $@ 2>&1 | grep -v "active configuration"
}

# Enables a single API:
enable_api() {
	gcloud services enable $1 >/dev/null 2>&1
	if [ ! $? -eq 0 ]; then
		echo -e "\n  ! - Error enabling $1"
		exit 1
	fi
}

# =============================================================================
# Base sanity checking
# =============================================================================

# Notify on existence of potentially conflicting Terraform directory, in cases
# where this script was executed yet the state has drifted:
if [ -d .terraform ]; then
	echo -e "\nWarning: An existing '.terraform/' state directory was found. If this
  causes issues, remove it and re-run this script.\n"
fi

# Check for our requisite binaries:
echo "Checking for requisite binaries..."
check_command gcloud "Please install the Google Cloud SDK from: https://cloud.google.com/sdk/downloads"
check_command terraform "Visit https://www.terraform.io/downloads.html for more information."

# This executes all the gcloud commands in parallel and then assigns them to separate variables:
# Needed for non-array capabale bashes, and for speed.
echo "Checking gcloud variables..."
PARAMS=$(cat <(gcloud_activeconfig_intercept config get-value compute/zone) \
	<(gcloud_activeconfig_intercept config get-value compute/region) \
	<(gcloud_activeconfig_intercept config get-value project) \
	<(gcloud_activeconfig_intercept auth application-default print-access-token))
read GCP_ZONE GCP_REGION GCP_PROJECT GCP_AUTHTOKEN <<<$(echo $PARAMS)

# Check for our requisiste gcloud parameters:
check_config $GCP_PROJECT "project"
check_config $GCP_REGION "compute/region"
check_config $GCP_ZONE "compute/zone"

# Check credentials are set:
printf '%-50s' " - 'application-default access token'..."
if [[ $GCP_AUTHTOKEN == *"ERROR"* ]]; then
	echo "[ UNSET ]"
	error "You do not have application-default credentials set, please run this command:
	gcloud auth application-default login"
	exit 1
fi
echo "[ OK ]"

# =============================================================================
# Initialization and idempotent test/setting
# =============================================================================

# List of requisite APIs:
REQUIRED_APIS="
	cloudresourcemanager
	compute container
	dns
	iam
	replicapool
	replicapoolupdater
	resourceviews
	sql-component
	sqladmin
	storage-api
	storage-component
"

# Bulk parrallel process all of the API enablement:
echo "Checking requisiste GCP APIs..."

# Read-in our currently enabled APIs, less the googleapis.com part:
GCP_CURRENT_APIS=$(gcloud services list | grep -v NAME | cut -f1 -d'.')

# Keep track of whether we modified the API state for friendliness:
ENABLED_ANY=1

for REQUIRED_API in $REQUIRED_APIS; do
	if [ $(grep -q $REQUIRED_API <(echo $GCP_CURRENT_APIS))$? -eq 0 ]; then
		# It's already enabled:
		printf '%-50s' " - $REQUIRED_API"
		echo "[ ON ]"
	else
		# It needs to be enabled:
		printf '%-50s' " + $REQUIRED_API"
		enable_api $REQUIRED_API.googleapis.com &
		ENABLED_ANY=0
		echo "[ OFF ]"
	fi
done

# If we've enabeld any API, wait for child processes to finish:
if [ $ENABLED_ANY -eq 0 ]; then
	printf '%-50s' " Concurrently enabling APIs..."
	wait

else
	printf '%-50s' " API status..."
fi
echo "[ OK ]"

TERRAFORM_BUCKET=$GCP_PROJECT-cloudlamp-terraform

# Create a GCS bucket for Terraform state; ignore if it's already there:
printf '%-50s' "Checking/creating Terraform state bucket..."
BUCKET_STATUS=$(gsutil mb -l $GCP_REGION -c Regional gs://$TERRAFORM_BUCKET 2>&1)
if [[ $? != 0 ]]; then
	if [[ $BUCKET_STATUS != *"409"* ]]; then
		error "Error creating Terraform state bucket:\n\n$BUCKET_STATUS"
		exit 1
	fi
fi
echo "[ OK ]"

# Create backend Terraform file:
printf '%-50s' "Creating Terraform backend file..."
cat <<EOF >backend.tf
# Note: This file is generated from preflight.sh:
terraform {
 backend "gcs" {
   bucket  = "$TERRAFORM_BUCKET"
   prefix  = "/tf/terraform.tfstate"
   project = "$GCP_PROJECT"
 }
}
EOF
echo "[ OK ]"

# Populate Terraform default variables:
printf '%-50s' "Creating Terraform variables file..."
cat <<EOF >terraform.tfvars
# Note: This file is generated from preflight.sh:
gcp_region  = "$GCP_REGION"
gcp_zone    = "$GCP_ZONE"
gcp_project = "$GCP_PROJECT"
EOF
echo "[ OK ]"

# Initialize Terraform with the 3 requisite providers:
terraform init

echo "
Success! You are now ready to deploy CloudLAMP via Terraform via:
  terraform [ plan | apply ]
"
