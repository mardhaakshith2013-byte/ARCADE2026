#!/bin/bash
# =====================================================================
#  Interact with Terraform Modules
#  Managed and Optimized by DR. M. AKSHITH
#  Lab ID: GSP572
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

TOTAL_PHASES=6
START_TIME=$(date +%s)

# ----------------------------- Optional Override -----------------------
ALLOWED_REGION_OVERRIDE=""

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
echo -e "${BLUE_TEXT}${BOLD}🚀 Lab ID Focus: GSP572 — Interact with Terraform Modules 🚀${RESET_FORMAT}"
echo

# ----------------------------- Phase 1: Region Detection -------------------------
print_phase "1" "🌍  Detecting Project & Region"
export PROJECT_ID=$(gcloud config get-value project)

if [ -n "$ALLOWED_REGION_OVERRIDE" ]; then
  export REGION="$ALLOWED_REGION_OVERRIDE"
  info "Using manual override region"
elif [ -n "$GOOGLE_CLOUD_REGION" ]; then
  export REGION="$GOOGLE_CLOUD_REGION"
  info "Region sourced from \$GOOGLE_CLOUD_REGION"
elif [ -n "$CLOUDSHELL_ENVIRONMENT" ]; then
  DETECTED_ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items.google-compute-default-zone)")
  if [ -n "$DETECTED_ZONE" ]; then
    export REGION=$(echo "$DETECTED_ZONE" | sed 's/-[a-z]$//')
    info "Region derived from Cloud Shell default zone"
  fi
fi

if [ -z "$REGION" ]; then
  DETECTED_ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print $NF}')
  if [ -n "$DETECTED_ZONE" ]; then
    export REGION=$(echo "$DETECTED_ZONE" | sed 's/-[a-z]$//')
    info "Region derived from instance metadata"
  fi
fi

if [ -z "$REGION" ] || [ "$REGION" == "null" ]; then
  export REGION="us-central1"
  warn "Falling back to default region us-central1"
fi

success "Project ID: ${WHITE}$PROJECT_ID${NC}"
success "Region:     ${WHITE}$REGION${NC}"

# ----------------------------- Phase 2: Terraform Install -------------------------
print_phase "2" "📦  Installing Terraform"
cat << 'EOF' > ~/.customize_environment
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
EOF
bash ~/.customize_environment
success "Terraform installed: $(terraform --version | head -n1)"

# ----------------------------- Phase 3: Task 1 - VPC Module -------------------------
print_phase "3" "🛠️   Task 1: Deploying VPC via Registry Module"
cd ~ || exit
rm -rf terraform-google-network
git clone https://github.com/terraform-google-modules/terraform-google-network
cd terraform-google-network/examples/simple_project || exit
git checkout tags/v6.0.1 -b v6.0.1
success "Repository cloned and checked out at v6.0.1"

gcloud services enable cloudaicompanion.googleapis.com 2>/dev/null || warn "Could not enable Gemini API (non-blocking, continuing)"

cat << EOF > variables.tf
variable "project_id" {
  description = "The project ID to host the network in"
  default     = "$PROJECT_ID"
}
variable "network_name" {
  description = "The name of the network to be created"
  default     = "example-vpc"
}
EOF

cat << EOF > main.tf
module "test-vpc-module" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = var.project_id
  network_name = var.network_name
  mtu          = 1460
  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "$REGION"
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "$REGION"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
    {
      subnet_name               = "subnet-03"
      subnet_ip                 = "10.10.30.0/24"
      subnet_region             = "$REGION"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      subnet_flow_logs_filter   = "false"
    }
  ]
}
EOF

terraform init
terraform apply -auto-approve
success "VPC network and subnets deployed  (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 4: Task 2 - Storage Module -------------------------
print_phase "4" "🪣  Task 2: Deploying Custom Storage Bucket Module"
rm -rf ~/gcp-storage-lab
mkdir -p ~/gcp-storage-lab/modules/gcp_storage_bucket
cd ~/gcp-storage-lab || exit

cat << EOF > main.tf
provider "google" {
  project = "$PROJECT_ID"
  region  = "$REGION"
}

module "gcp_storage_bucket" {
  source      = "./modules/gcp_storage_bucket"
  bucket_name = "${PROJECT_ID}-bucket"
}
EOF

cd modules/gcp_storage_bucket || exit

cat << 'EOF' > variables.tf
variable "bucket_name" {
  description = "The name of the storage bucket"
  type        = string
}
EOF

cat << EOF > main.tf
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = "$REGION"
  force_destroy = true
}

resource "google_storage_bucket_object" "index" {
  name    = "index.html"
  bucket  = google_storage_bucket.bucket.name
  content = "<html><body><h1>Welcome to my website!</h1></body></html>"
}

resource "google_storage_bucket_object" "error" {
  name    = "error.html"
  bucket  = google_storage_bucket.bucket.name
  content = "<html><body><h1>Error: Page not found!</h1></body></html>"
}
EOF

cd ../../ || exit
terraform init
terraform apply -auto-approve
success "Storage bucket module deployed  (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 5: Destroy Task 1 -------------------------
print_phase "5" "🧹  Cleaning Up Task 1 Infrastructure"
info "Lab requirement: Task 1 resources must be destroyed after Task 2 is verified"
cd ~/terraform-google-network/examples/simple_project || exit
terraform destroy -auto-approve
success "Task 1 infrastructure destroyed  (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Phase 6: Completion Summary -----------------------------
TOTAL_TIME=$(elapsed_since_start)
print_phase "6" "🎉  Lab Complete"
echo -e "${WHITE_TEXT}  Current state:${RESET_FORMAT}"
echo -e "${CYAN}   ├─${NC} Task 1 VPC network        ${RED}destroyed${NC}  (as required)"
echo -e "${CYAN}   └─${NC} Task 2 storage bucket     ${GREEN}${PROJECT_ID}-bucket${NC}  (still live — index.html + error.html)"
echo
echo -e "${MAGENTA_TEXT}   ⏱  Total run time: ${TOTAL_TIME}s${RESET_FORMAT}"
echo
gradient_line
echo -e "${GREEN_TEXT}"
echo "   🎉  LAB COMPLETE! Click \"Check My Progress\" for both tasks.  🎉"
echo -e "${RESET_FORMAT}"
gradient_line

# ====== Footer Info ======
echo
echo -e "${RED_TEXT}   🎥  SUBSCRIBE ON YOUTUBE:${RESET_FORMAT}"
echo -e "${WHITE_TEXT}   https://youtube.com/@dr.m.akshith?sub_confirmation=1${RESET_FORMAT}"
echo -e "${CYAN_TEXT}   🐙  FOLLOW ON GITHUB:${RESET_FORMAT}"
echo -e "${WHITE_TEXT}   https://github.com/mardhaakshith2013-byte${RESET_FORMAT}"
echo
echo -e "${DIM}   CREDIT: GOOGLE SKILLS ARCADE${NC}"
echo
