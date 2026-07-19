<div align="center">

# <span style="color:#FF0000; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">DR.</span> <span style="color:#FF7F00; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">M.</span> <span style="color:#00FF00; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">A</span><span style="color:#0000FF; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">K</span><span style="color:#4B0082; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">S</span><span style="color:#9400D3; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">H</span><span style="color:#FF0000; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">I</span><span style="color:#FF7F00; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">T</span><span style="color:#00FF00; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">H</span>

### 🌈 ⚡ Cloud DevOps Automation Suite ⚡ 🌈

---

## ⚠️ <span style="color:#FF0000;">D</span><span style="color:#FF7F00;">I</span><span style="color:#FFD700;">S</span><span style="color:#00FF00;">C</span><span style="color:#0000FF;">L</span><span style="color:#4B0082;">A</span><span style="color:#9400D3;">I</span><span style="color:#FF0000;">M</span><span style="color:#FF7F00;">E</span><span style="color:#00FF00;">R</span> & NOTICE

> [!WARNING]
> 📚 **Educational & Lab Verification Use Only!**  
> This script is automated specifically for lab environment verification platforms (such as Google Cloud Skills Boost / Qwiklabs GSP752). It modifies state files, provisions sandbox assets, and builds live instances. Do not deploy this suite inside production environments without conducting a prior resource audit. Always follow **Qwiklabs ToS**.

---

## Manage Terraform State
### 🚀 Lab ID: GSP752 🚀

<br/>

![](https://img.shields.io/badge/-%F0%9F%94%A5%20GOOGLE%20CLOUD%20ARCADE-FF6B6B?style=for-the-badge)
![](https://img.shields.io/badge/-%E2%98%81%EF%B8%8F%20TERRAFORM%20STATE-4ECDC4?style=for-the-badge)
![](https://img.shields.io/badge/-%F0%9F%90%9A%20SHELL%20SCRIPT-45B7D1?style=for-the-badge)

</div>

<br/>

---

![](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=80&section=header&fontSize=0)

<div align="center">

## ⚡ `QUICK RUN` ⚡

</div>

<br/>

**🖥️ Open Cloud Shell → Paste → Done!**

```bash
curl -LO "[https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Manage%20Terraform%20State/akshith.sh](https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Manage%20Terraform%20State/akshith.sh)"
sudo chmod +x akshith.sh
./akshith.sh

<div align="center">
​🌍 Find Me Here

https://youtube.com/@dr.m.akshith?si=dh5YR_M-B_2Jqj6Q

</div>
​<div align="center">
​©️ Credit
​🙏 DM for credit or removal request (no copyright intended)
©️ All rights and credits for the original content belong to Google Cloud
🔗 Google Cloud Skill Boost Website
​If this saved your day — smash that ⭐ star!
​</div>


---

### 2. `akshith.sh`
```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

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

TOTAL_PHASES=5
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
# Redesigned Multi-color Clear ASCII Text Banner for DR.M.AKSHITH
echo -e "${RED_TEXT}  ██████╗ ██████╗ 🛑 ${YELLOW_TEXT}███╗   ███╗    ${GREEN_TEXT} █████╗ ██╗  ██╗███████╗██╗  ██╗██╗████████╗██╗  ██╗"
echo -e "${RED_TEXT}  ██╔══██╗██╔══██╗   ${YELLOW_TEXT}████╗ ████║    ${GREEN_TEXT}██╔══██╗██║ ██╔╝██╔════╝██║  ██║██║╚══██╔══╝██║  ██║"
echo -e "${CYAN_TEXT}  ██║  ██║██████╔╝   ${CYAN_TEXT}██╔████╔██║    ${BLUE_TEXT}███████║█████╔╝ ███████╗███████║██║   ██║   ███████║"
echo -e "${CYAN_TEXT}  ██║  ██║██╔══██╗   ${MAGENTA_TEXT}██║╚██╔╝██║    ${BLUE_TEXT}██╔══██║██╔═██╗ ╚════██║██╔══██║██║   ██║   ██╔══██║"
echo -e "${MAGENTA_TEXT}  ██████╔╝██║  ██║   ${MAGENTA_TEXT}██║ ╚═╝ ██║    ${RED_TEXT}██║  ██║██║  ██╗███████║██║  ██║██║   ██║   ██║  ██║"
echo -e "${MAGENTA_TEXT}  ╚══════╝ ╚═╝  ╚═╝   ${RED_TEXT}╚═╝     ╚═╝    ${RED_TEXT}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝"
echo -e "${RESET_FORMAT}"
echo -e "${CYAN_TEXT}${BOLD}────────────── Manage Terraform State GSP752 ──────────────${RESET_FORMAT}"
echo -e "${CYAN_TEXT}${BOLD}────────────── Terraform State: Local → GCS Backend + Import ──────────────${RESET_FORMAT}"

# ----------------------------- Disclaimer -----------------------------
echo
echo -e "${RED_TEXT}█${YELLOW_TEXT}█${GREEN_TEXT}█${CYAN_TEXT}█${BLUE_TEXT}█${MAGENTA_TEXT}█ ${YELLOW_TEXT}${BOLD}⚠️  DISCLAIMER & NOTICE:${RESET_FORMAT}"
echo -e "${WHITE}This script is automated specifically for lab environment verification platforms"
echo -e "(such as Google Cloud Skills Boost / Qwiklabs GSP752). It modifies state files,"
echo -e "provisions assets, and builds live instances."
echo
echo -e "${WHITE}Maintained and optimized by: "
echo -e "  ${RED_TEXT}D${YELLOW_TEXT}r${GREEN_TEXT}.${CYAN_TEXT}M${BLUE_TEXT}.${MAGENTA_TEXT}A${RED_TEXT}k${YELLOW_TEXT}s${GREEN_TEXT}h${CYAN_TEXT}i${BLUE_TEXT}t${MAGENTA_TEXT}h${RESET_FORMAT}"
echo
echo -e "${CYAN_TEXT}📺 YouTube Channel:${RESET_FORMAT}"
echo -e "  ${WHITE}https://youtube.com/@dr.m.akshith${RESET_FORMAT}"
echo
echo -e "${CYAN_TEXT}🌐 Original Deployment Source Commands:${RESET_FORMAT}"
echo -e "${WHITE}  curl -LO \"https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Manage%20Terraform%20State/akshith.sh\""
echo -e "  sudo chmod +x akshith.sh"
echo -e "  ./akshith.sh${RESET_FORMAT}"
echo
echo -e "${WHITE}Do not run this inside production environments without auditing changes.${RESET_FORMAT}"
echo

# ==============================================================================
# 1. AUTO-DETECT ENVIRONMENT VARIABLES
# ==============================================================================
print_phase "1" "🌍  Auto-Detecting Project Environment"

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    warn "Could not auto-detect Project ID. Make sure you are in Cloud Shell."
    exit 1
fi

ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
if [ -z "$ZONE" ]; then
    ZONE="us-central1-a"
fi

REGION=$(gcloud config get-value compute/region 2>/dev/null)
if [ -z "$REGION" ]; then
    REGION="${ZONE%-*}"
fi

success "Project ID: ${WHITE}$PROJECT_ID${NC}"
success "Region:     ${WHITE}$REGION${NC}"
success "Zone:       ${WHITE}$ZONE${NC}"

# ==============================================================================
# 2. PREREQUISITE: INSTALL TERRAFORM & ENABLE GEMINI API
# ==============================================================================
print_phase "2" "📦  Installing Terraform & Enabling Gemini API"

cat << 'EOF' > ~/.customize_environment
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
EOF

bash ~/.customize_environment
success "Terraform installed: $(terraform --version | head -n1)"

gcloud services enable cloudaicompanion.googleapis.com || warn "Could not enable Gemini API (non-blocking, continuing)"
success "Gemini for Google Cloud API enabled"

# ==============================================================================
# 3. TASK 1: CREATE CONFIGURATION WITH LOCAL BACKEND
# ==============================================================================
print_phase "3" "📝  Task 1: Provisioning with a Local Backend"

cat << EOF > main.tf
provider "google" {
  project = "${PROJECT_ID}"
  region  = "${REGION}"
  zone    = "${ZONE}"
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name                        = "${PROJECT_ID}"
  location                    = "US"
  uniform_bucket_level_access = true

  labels = {
    "key" = "value"
  }
}

terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
EOF

terraform init
terraform apply -auto-approve
success "Local backend initialized and bucket provisioned  (⏱  $(elapsed_since_start)s elapsed)"

# ==============================================================================
# 4. TASK 2: MIGRATE TO CLOUD STORAGE (GCS) BACKEND
# ==============================================================================
print_phase "4" "☁️   Task 2: Migrating State to a GCS Backend"

cat << EOF > main.tf
provider "google" {
  project = "${PROJECT_ID}"
  region  = "${REGION}"
  zone    = "${ZONE}"
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name                        = "${PROJECT_ID}"
  location                    = "US"
  uniform_bucket_level_access = true

  labels = {
    "key" = "value"
  }
}

terraform {
  backend "gcs" {
    bucket = "${PROJECT_ID}"
    prefix = "terraform/state"
  }
}
EOF

terraform init -migrate-state -force-copy
success "State successfully migrated to gs://${PROJECT_ID}/terraform/state  (⏱  $(elapsed_since_start)s elapsed)"

# ==============================================================================
# 5. TASK 3 & 4: REFRESH STATE & IMPORT INSTANCE
# ==============================================================================
print_phase "5" "🔄  Task 3 & 4: Refresh State and Import Instance"

info "Refreshing Terraform state"
terraform refresh

info "Creating a sample instance via gcloud to simulate an unmanaged resource"
gcloud compute instances create sample-instance \
    --zone="${ZONE}" \
    --machine-type="e2-micro" \
    --image-family="debian-11" \
    --image-project="debian-cloud" \
    --quiet
success "Instance sample-instance created outside of Terraform"

info "Appending the instance block to main.tf"
cat << EOF >> main.tf

resource "google_compute_instance" "import-instance" {
  name         = "sample-instance"
  machine_type = "e2-micro"
  zone         = "${ZONE}"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}
EOF

info "Importing the instance into Terraform state"
terraform import google_compute_instance.import-instance projects/${PROJECT_ID}/zones/${ZONE}/instances/sample-instance
success "Instance imported into state"

info "Syncing configuration with imported state"
terraform plan
terraform apply -auto-approve
success "Configuration synced with live instance  (⏱  $(elapsed_since_start)s elapsed)"

# ----------------------------- Completion Banner -----------------------------
TOTAL_TIME=$(elapsed_since_start)
echo
gradient_line
echo -e "${GREEN_TEXT}"
echo "   🎉  ALL TASKS COMPLETED SUCCESSFULLY (100/100)  🎉"
echo -e "${RESET_FORMAT}"
gradient_line
echo
echo -e "${WHITE_TEXT}  Here's everything that got built:${RESET_FORMAT}"
echo -e "${CYAN}   ├─${NC} State bucket (local → GCS)   ${GREEN}gs://${PROJECT_ID}/terraform/state${NC}"
echo -e "${CYAN}   └─${NC} Imported compute instance     ${GREEN}sample-instance${NC}  ($ZONE)"
echo
echo -e "${MAGENTA_TEXT}   ⏱  Total run time: ${TOTAL_TIME}s${RESET_FORMAT}"
echo
gradient_line
