#!/bin/bash

# Color definitions using tput
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}          Welcome to Dr. M. Akshith Tutorials!           ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}Please like, share and subscribe to the channel for more:${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

echo "${YELLOW}${BOLD}Starting Terraform Instance Creation Lab...${RESET}"

# Show current authentication
echo "${MAGENTA}${BOLD}Current gcloud authentication:${RESET}"
gcloud auth list
echo

# Automatically detect the zone from gcloud config, fallback to us-central1-a if empty
ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
if [ -z "$ZONE" ]; then
    ZONE="us-central1-a"
fi

echo "${BLUE}${BOLD}Using Zone: $ZONE${RESET}"
echo "${BLUE}${BOLD}Using Project ID: $DEVSHELL_PROJECT_ID${RESET}"
echo

# Create Terraform configuration file
echo "${GREEN}${BOLD}Creating Terraform configuration file...${RESET}"
cat > instance.tf <<EOF_END
resource "google_compute_instance" "terraform" {
  project      = "$DEVSHELL_PROJECT_ID"
  name         = "terraform"
  machine_type = "e2-medium"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}
EOF_END

# Initialize Terraform
echo "${YELLOW}${BOLD}Initializing Terraform...${RESET}"
terraform init

# Plan Terraform changes
echo "${BLUE}${BOLD}Planning Terraform changes...${RESET}"
terraform plan

# Apply Terraform changes
echo "${GREEN}${BOLD}Applying Terraform changes...${RESET}"
terraform apply --auto-approve

echo
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}            Lab Completed Successfully!                  ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}Thanks for using this lab! Don't forget to:${RESET}"
echo "${YELLOW}${BOLD}👍 Like    🔄 Share    🔔 Subscribe${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo
