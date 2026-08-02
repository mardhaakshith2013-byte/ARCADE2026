#!/bin/bash
# =======================================================
#           DR. M. AKSHITH CLOUD LABS
#      GCP Quick Automation Script Template
# =======================================================
# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BG_BLUE='\033[44m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 0. Matrix-style green binary intro (5 seconds, full screen)
matrix_intro() {
    tput civis 2>/dev/null
    clear
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    local end=$((SECONDS + 5))
    while [ $SECONDS -lt $end ]; do
        local line=""
        for ((i = 0; i < cols; i++)); do
            line+="$((RANDOM % 2))"
        done
        echo -e "${GREEN}${line}${NC}"
        sleep 0.05
    done
    clear
    tput cnorm 2>/dev/null
}
matrix_intro

# 1. Header Banner
echo -e "${BG_BLUE}${BOLD}=======================================================${NC}"
echo -e "${BG_BLUE}${BOLD}       DR. M. AKSHITH CLOUD LABS - STARTING LAB        ${NC}"
echo -e "${BG_BLUE}${BOLD}=======================================================${NC}\n"

# 2. Get and Set Region Automatically
LOCATION=$(gcloud config get-value compute/region 2>/dev/null)
if [ -z "$LOCATION" ]; then
  LOCATION="us-central1"
  gcloud config set compute/region $LOCATION
fi
echo -e "${BLUE}Using Region: ${LOCATION}${NC}"

# 3. Enable Common GCP APIs (Add or remove APIs as needed)
echo -e "${YELLOW}Enabling necessary GCP Services...${NC}"
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com
echo -e "${GREEN}APIs successfully enabled!${NC}"
sleep 3

# 4. Your Lab Automation Logic Here
echo -e "${YELLOW}Executing core lab steps...${NC}"
# --- ADD YOUR LAB COMMANDS BELOW THIS LINE ---
echo "Running automation tasks..."
# --- ADD YOUR LAB COMMANDS ABOVE THIS LINE ---

# 5. Success Message & Channel Branding
echo -e "\n${GREEN}${BOLD}=======================================================${NC}"
echo -e "${GREEN}${BOLD}   Cloud Run Functions: Qwik Start — COMPLETED!        ${NC}"
echo -e "${GREEN}${BOLD}    TASK COMPLETED SUCCESSFULLY! CHECK YOUR SCORE!    ${NC}"
echo -e "${GREEN}${BOLD}         SUBSCRIBE TO: DR. M. AKSHITH                 ${NC}"
echo -e "${GREEN}${BOLD}=======================================================${NC}"
