#!/bin/bash
# =====================================================================
#  Build Infrastructure with Terraform on Google Cloud: Challenge Lab
#  Fully Automated & Optimized by DR. M. AKSHITH
#  Lab ID: GSP345
# =====================================================================

# ----------------------------- Color Palette --------------------------
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

BLUE_TEXT="${BLUE}${BOLD}"
GREEN_TEXT="${GREEN}${BOLD}"
YELLOW_TEXT="${YELLOW}${BOLD}"
RED_TEXT="${RED}${BOLD}"
CYAN_TEXT="${CYAN}${BOLD}"
MAGENTA_TEXT="${MAGENTA}${BOLD}"
WHITE_TEXT="${WHITE}${BOLD}"
RESET_FORMAT="${NC}"

TOTAL_PHASES=7
START_TIME=$(date +%s)

# ----------------------------- Helper Functions ------------------------
gradient_line() {
  echo -e "${BLUE}▓${LBLUE}▓${CYAN}▓${GREEN}▓${YELLOW}▓${MAGENTA}▓${RED}▓${NC}$(printf '━%.0s' {1..55})"
}

print_phase() {
  local step=$1
  local title=$2
  echo
  gradient_line
  echo -e "${YELLOW_TEXT}  [${step}/${TOTAL_PHASES}] ${title}${RESET_FORMAT}"
  gradient_line
}

success() { echo -e "${GREEN_TEXT}   ✅  $1${RESET_FORMAT}"; }
info()    { echo -e "${CYAN_TEXT}   ℹ️   $1${RESET_FORMAT}"; }
warn()    { echo -e "${RED_TEXT}   ⚠️   $1${RESET_FORMAT}"; }

elapsed_since_start() {
  local now=$(date +%s)
  echo $(( now - START_TIME ))
}

# ----------------------------- Welcome Banner --------------------------
clear
echo -e "${RED}${BOLD}██████╗ ██████╗     ███╗   ███╗     █████╗ ██║  ██║███████╗██║███████╗██║  ██║${NC}"
echo -e "${YELLOW}██╔══██╗██╔══██╗    ████╗ ████║    ██╔══██╗██║  ██║██╔════╝██║██╔════╝██║  ██║${NC}"
echo -e "${GREEN}██║  ██║██████╔╝    ██╔████╔██║    ███████║███████║███████╗██║███████╗███████║${NC}"
echo -e "${CYAN}██║  ██║██╔══██╗    ██║╚██╔╝██║    ██╔══██║██╔══██║╚════██║██║╚════██║██╔══██║${NC}"
echo -e "${MAGENTA}██████╔╝██║  ██║    ██║ ╚═╝ ██║    ██║  ██║██║  ██║███████║██║███████║██║  ██║${NC}"
echo -e "${BLUE}╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝${NC}"
echo
echo -e "${CYAN_TEXT}${BOLD}🌈 ⚡ DR.M.AKSHITH × CLOUD 🌈 ⚡${RESET_FORMAT}"
echo -e "${BLUE_TEXT}${BOLD}🚀 Lab ID Focus: GSP345 — Challenge Lab Suite 🚀${RESET_FORMAT}"
echo

# ----------------------------- Phase 1: Auto-Context Detection -------------------------
print_phase "1" "🌍  Autodetecting Project Infrastructure Context"

export PROJECT_ID=$DEVSHELL_PROJECT_ID
if [ -z "$PROJECT_ID" ]; then
  export PROJECT_ID=$(gcloud config get-value project)
fi

DETECTED_ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items.google-compute-default-zone)")
if [ -z "$DETECTED_ZONE" ] || [ "$DETECTED_ZONE" == "null" ]; then
  DETECTED_ZONE=$(gcloud compute instances list --limit=1 --format="value(zone)")
fi
if [ -z "$DETECTED_ZONE" ] || [ "$DETECTED_ZONE" == "null" ]; then
  export ZONE="us-east1-b"
else
  export ZONE="$DETECTED_ZONE"
fi
export REGION=$(echo "$ZONE" | cut -d '-' -f 1-2)

export BUCKET="tf-bucket-$PROJECT_ID"
export INSTANCE="tf-instance-3"
export VPC="tf-vpc"

instances_output=$(gcloud compute instances list --format="value(id)")
IFS=$'\n' read -r -d '' instance_id_1 instance_id_2 <<< "$instances_output"
export INSTANCE_ID_1=$instance_id_1
export INSTANCE_ID_2=$instance_id_2

gcloud config set compute/zone "$ZONE" &>/dev/null
gcloud config set compute/region "$REGION" &>/dev/null

success "Target Project:  ${WHITE}$PROJECT_ID${NC}"
success "Target Region:   ${WHITE}$REGION${NC}"
success "Target Zone:     ${WHITE}$ZONE${NC}"
success "Target Bucket:   ${WHITE}$BUCKET${NC}"
success "Target VPC:      ${WHITE}$VPC${NC}"

# ----------------------------- Phase 2: Setup Workspace -------------------------
print_phase "2" "📁  Initializing Module Directory Structure"
mkdir -p modules/instances modules/storage
touch main.tf variables.tf
touch modules/instances/instances.tf modules/instances/outputs.tf modules/instances/variables.tf
touch modules/storage/storage.tf modules/storage/outputs.tf modules/storage/variables.tf

cat > variables.tf <<EOF
variable "region" { default = "$REGION" }
variable "zone" { default = "$ZONE" }
variable "project_id" { default = "$PROJECT_ID" }
EOF

cat > main.tf <<EOF
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.0"
    }
  }
}
provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}
module "instances" {
  source     = "./modules/instances"
}
EOF

terraform init
success "Base configuration initiated (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 3: Resource Import -------------------------
print_phase "3" "📥  Importing Unmanaged Compute Resources"

cat > modules/instances/instances.tf <<EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "n1-standard-1"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "n1-standard-1"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}
EOF

terraform import module.instances.google_compute_instance.tf-instance-1 "$INSTANCE_ID_1"
terraform import module.instances.google_compute_instance.tf-instance-2 "$INSTANCE_ID_2"

terraform plan
terraform apply --auto-approve
success "Existing infrastructure successfully attached to state (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 4: Build GCS Storage -------------------------
print_phase "4" "🪣  Provisions Remote Backend Storage Module"

cat > modules/storage/storage.tf <<EOF
resource "google_storage_bucket" "storage-bucket" {
  name                        = "$BUCKET"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}
EOF

cat >> main.tf <<EOF
module "storage" {
  source     = "./modules/storage"
}
EOF

terraform init
terraform apply --auto-approve
success "Storage layers created (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 5: Migrating Backend State -------------------
print_phase "5" "🔄  Migrating Local State to Google Cloud Storage"

cat > main.tf <<EOF
terraform {
  backend "gcs" {
    bucket  = "$BUCKET"
    prefix  = "terraform/state"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.0"
    }
  }
}
provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}
module "instances" { source = "./modules/instances" }
module "storage"   { source = "./modules/storage" }
EOF

echo "yes" | terraform init -migrate-state
success "State target migrated to cloud storage bucket (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 6: Instance Scale & Taint -------------------
print_phase "6" "⚡  Scaling Machine Topology & Managing Lifecycle"

cat > modules/instances/instances.tf <<EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}

resource "google_compute_instance" "$INSTANCE" {
  name         = "$INSTANCE"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}
EOF

terraform init
terraform apply --auto-approve

terraform taint module.instances.google_compute_instance."$INSTANCE"
terraform init
terraform plan
terraform apply --auto-approve

cat > modules/instances/instances.tf <<EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}
EOF

terraform apply --auto-approve
success "Topology scaled and node cycle verification complete (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 7: Custom Module Networking -----------------
print_phase "7" "🌐  Deploying Modular VPC & Security Enforcements"

cat >> main.tf <<EOF
module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 6.0.0"
    project_id   = "$PROJECT_ID"
    network_name = "$VPC"
    routing_mode = "GLOBAL"
    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "$REGION"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "$REGION"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "Custom subnet built via automated configuration suite."
        },
    ]
}
EOF

terraform init
terraform plan
terraform apply --auto-approve

cat > modules/instances/instances.tf <<EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface {
    network    = "$VPC"
    subnetwork = "subnet-01"
  }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface {
    network    = "$VPC"
    subnetwork = "subnet-02"
  }
  metadata_startup_script = "#!/bin/bash"
  allow_stopping_for_update = true
}
EOF

terraform init
terraform plan
terraform apply --auto-approve

cat >> main.tf <<EOF
resource "google_compute_firewall" "tf-firewall"{
  name    = "tf-firewall"
  network = "projects/$PROJECT_ID/global/networks/$VPC"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_tags   = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
EOF

terraform init
terraform plan
terraform apply --auto-approve
success "Advanced Network Topologies and Firewall Rules active (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Completion Summary -----------------------------
TOTAL_TIME=$(elapsed_since_start)
echo
gradient_line
echo -e "${GREEN_TEXT}   🎉  LAB COMPLETED SUCCESSFULLY! (⏱  Total: ${TOTAL_TIME}s)  🎉${RESET_FORMAT}"
gradient_line
echo
echo -e "${RED_TEXT}   🎥  SUBSCRIBE ON YOUTUBE:${RESET_FORMAT}"
echo -e "${WHITE_TEXT}   https://youtube.com/@dr.m.akshith?sub_confirmation=1${RESET_FORMAT}"
echo -e "${CYAN_TEXT}   🐙  FOLLOW ON GITHUB:${RESET_FORMAT}"
echo -e "${WHITE_TEXT}   https://github.com/mardhaakshith2013-byte${RESET_FORMAT}"
echo
echo -e "${DIM}   CREDIT: GOOGLE SKILLS ARCADE${NC}"
echo
