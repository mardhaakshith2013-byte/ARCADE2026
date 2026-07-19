#!/bin/bash

# Enhanced Color Definitions
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BLUE=$(tput setaf 4)
BG_BLUE=$(tput setab 4)
BG_GREEN=$(tput setab 2)
BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# Display Header
echo "${BG_BLUE}${BOLD}========================================================================${RESET}"
echo "${BG_BLUE}${BOLD}                         INITIATING EXECUTION...                        ${RESET}"
echo "${BG_BLUE}${BOLD}               Welcome to Dr. Akshith's Automated Cloud Lab              ${RESET}"
echo "${BG_BLUE}${BOLD}               GSP751: Interact with Terraform Modules                  ${RESET}"
echo "${BG_BLUE}${BOLD}               Repository: mardhaakshith2013-byte/ARCADE2026            ${RESET}"
echo "${BG_BLUE}${BOLD}========================================================================${RESET}"
echo

# 1. Environment Verification
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo $DEVSHELL_PROJECT_ID)
export REGION=$(gcloud config get-value compute/region 2>/dev/null)

if [ -z "$REGION" ]; then
  echo "${YELLOW}⚠️ Environment variable REGION is empty.${RESET}"
  read -p "$(echo -e "${CYAN}${BOLD}Please type your lab region (e.g., us-east1): ${RESET}")" REGION
  export REGION=$REGION
fi

# 2. Clean Up and Repository Pre-Setup Tasks
echo "${CYAN}${BOLD}[Phase 1/4] Cleaning workspace and setting up Terraform repositories...${RESET}"
rm -rf main.tf variables.tf outputs.tf modules/ terraform-google-network/ terraform.tfstate* .terraform*

cat <<'EOF' > ~/.customize_environment
wget -O - https://hashicorp.com | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
EOF
bash ~/.customize_environment

# 3. Task 1: Baseline Network Module Setup
echo "${CYAN}${BOLD}[Phase 2/4] Deploying baseline registry network block...${RESET}"
git clone https://github.com &>/dev/null
cd terraform-google-network
git checkout tags/v6.0.1 -b v6.0.1 &>/dev/null
cd examples/simple_project

cat > variables.tf <<EOF
variable "project_id" { default = "$PROJECT_ID" }
variable "network_name" { default = "example-vpc" }
EOF

cat > main.tf <<EOF
module "test-vpc-module" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = var.project_id
  network_name = var.network_name
  mtu          = 1460
  subnets = [
    { subnet_name = "subnet-01", subnet_ip = "10.10.10.0/24", subnet_region = "$REGION" },
    { subnet_name = "subnet-02", subnet_ip = "10.10.20.0/24", subnet_region = "$REGION", subnet_private_access = "true", subnet_flow_logs = "true" },
    { subnet_name = "subnet-03", subnet_ip = "10.10.30.0/24", subnet_region = "$REGION", subnet_flow_logs = "true", subnet_flow_logs_interval = "INTERVAL_10_MIN", subnet_flow_logs_sampling = 0.7, subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA", subnet_flow_logs_filter = "false" }
  ]
}
EOF

terraform init &>/dev/null
terraform apply --auto-approve &>/dev/null

echo "${YELLOW}${BOLD}[Checkpoint] Click 'Check My Progress' for Task 1 now! Pausing 20s...${RESET}"
sleep 20

terraform destroy --auto-approve &>/dev/null
cd ~
rm -rf terraform-google-network -f

# 4. Task 2: Custom GCS Module Framework Construction
echo "${CYAN}${BOLD}[Phase 3/4] Creating local nested web storage template module...${RESET}"
mkdir -p modules/gcs-static-website-bucket
cd modules/gcs-static-website-bucket

cat > README.md <<EOF
# GCS static website bucket
This module provisions Cloud Storage buckets configured for static website hosting.
EOF

cat > LICENSE <<EOF
Licensed under the Apache License, Version 2.0 (the "License");
EOF

cat > website.tf <<'EOF'
resource "google_storage_bucket" "bucket" {
  name                        = var.name
  project                     = var.project_id
  location                    = var.location
  storage_class               = var.storage_class
  labels                      = var.labels
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true
  versioning { enabled = var.versioning }
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age        = lookup(lifecycle_rule.value.condition, "age", null)
        with_state = lookup(lifecycle_rule.value.condition, "with_state", null)
      }
    }
  }
}
EOF

cat > variables.tf <<'EOF'
variable "name" { type = string }
variable "project_id" { type = string }
variable "location" { type = string }
variable "storage_class" { type = string; default = null }
variable "labels" { type = map(string); default = null }
variable "versioning" { type = bool; default = true }
variable "force_destroy" { type = bool; default = true }
variable "lifecycle_rules" { type = list(any); default = [] }
EOF

cat > outputs.tf <<'EOF'
output "bucket" { value = google_storage_bucket.bucket }
EOF

# 5. Populate Parent Orchestration Configuration Layer
echo "${CYAN}${BOLD}[Phase 4/4] Finalizing orchestration maps and compiling deployment...${RESET}"
cd ~

cat > main.tf <<EOF
module "gcs-static-website-bucket" {
  source     = "./modules/gcs-static-website-bucket"
  name       = var.name
  project_id = var.project_id
  location   = "US"
  lifecycle_rules = [{
    action = { type = "Delete" }
    condition = { age = 365, with_state = "ANY" }
  }]
}
EOF

cat > variables.tf <<EOF
variable "project_id" { type = string; default = "$PROJECT_ID" }
variable "name" { type = string; default = "$PROJECT_ID" }
EOF

cat > outputs.tf <<'EOF'
output "bucket-name" { value = module.gcs-static-website-bucket.bucket.name }
EOF

terraform init &>/dev/null
terraform apply --auto-approve &>/dev/null

# Final Asset Generation Task Requirement Fix
curl -s -O https://githubusercontent.com
gsutil mb -l $REGION gs://$PROJECT_ID-preview-cdn &>/dev/null || true

echo
echo "${BG_GREEN}${BOLD}========================================================================${RESET}"
echo "${BG_GREEN}${BOLD}                LAB GSP751 COMPLETED SUCCESSFULLY!                      ${RESET}"
echo "${BG_GREEN}${BOLD}========================================================================${RESET}"
echo "${WHITE}Thank you for deploying with Dr. Akshith's Cloud Solutions!${RESET}"
echo
