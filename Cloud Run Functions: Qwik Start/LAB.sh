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

# 2. Ask for Region and Zone (varies per lab session, so don't assume a default)
while [[ ! "$REGION" =~ ^[a-z]+-[a-z]+[0-9]$ ]]; do
  if [ -n "$REGION" ]; then
    echo -e "${RED}'$REGION' isn't a valid region. Type ONLY the value, e.g. us-central1.${NC}"
  fi
  read -p "👉 Enter REGION for this lab (e.g. us-central1): " REGION
done

while [[ ! "$ZONE" =~ ^[a-z]+-[a-z]+[0-9]-[a-z]$ ]]; do
  if [ -n "$ZONE" ]; then
    echo -e "${RED}'$ZONE' isn't a valid zone. Type ONLY the value, e.g. us-central1-a.${NC}"
  fi
  read -p "👉 Enter ZONE for this lab (e.g. us-central1-a): " ZONE
done

export REGION
export ZONE
gcloud config set compute/region "$REGION" > /dev/null
gcloud config set compute/zone "$ZONE" > /dev/null
echo -e "${BLUE}Using Region: ${REGION}${NC}"
echo -e "${BLUE}Using Zone: ${ZONE}${NC}"

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
