#!/bin/bash

# ==========================================
# Script by: DR.M.AKSHITH
# YouTube: https://youtube.com/@dr.m.akshith
# Lab: Cloud Run Functions: Qwik Start - Console (GSP081/GSP080)
# ==========================================

# Enhanced Color Definitions
COLOR_BLACK=$'\033[0;30m'
COLOR_RED=$'\033[0;31m'
COLOR_GREEN=$'\033[0;32m'
COLOR_YELLOW=$'\033[0;33m'
COLOR_BLUE=$'\033[0;34m'
COLOR_MAGENTA=$'\033[0;35m'
COLOR_CYAN=$'\033[0;36m'
COLOR_WHITE=$'\033[0;37m'
COLOR_RESET=$'\033[0m'

# Text Formatting
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
BLINK=$'\033[5m'
REVERSE=$'\033[7m'

clear

# ---------- Matrix-style binary intro (10 seconds, full screen) ----------
matrix_intro() {
    tput civis 2>/dev/null
    clear
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    local end=$((SECONDS + 10))
    local name="DR.M.AKSHITH"
    local current_color="$COLOR_GREEN"
    local last_switch=$SECONDS
    local frame=0
    while [ $SECONDS -lt $end ]; do
        if [ $((SECONDS - last_switch)) -ge 1 ]; then
            if [ "$current_color" = "$COLOR_GREEN" ]; then
                current_color="$COLOR_BLUE"
            else
                current_color="$COLOR_GREEN"
            fi
            last_switch=$SECONDS
        fi

        frame=$((frame + 1))
        local line=""
        if [ $((frame % 6)) -eq 0 ]; then
            local pad=$(( (cols - ${#name}) / 2 ))
            [ $pad -lt 0 ] && pad=0
            line=$(printf '%*s' "$pad" '')
            line+="$name"
        else
            for ((i = 0; i < cols; i++)); do
                line+="$((RANDOM % 2))"
            done
        fi
        echo -e "${current_color}${BOLD}${line}${COLOR_RESET}"
        sleep 0.05
    done
    clear
    tput cnorm 2>/dev/null
}

# ---------- Big bold name banner ----------
big_text() {
    if command -v figlet &> /dev/null; then
        echo -e "${COLOR_BLUE}${BOLD}"
        figlet "$1"
        echo -e "${COLOR_RESET}"
    else
        echo -e "${COLOR_BLUE}${BOLD}"
        echo "   $1   "
        echo -e "${COLOR_RESET}"
    fi
}

if ! command -v figlet &> /dev/null; then
    sudo apt-get update -qq &> /dev/null
    sudo apt-get install -y figlet -qq &> /dev/null
fi

matrix_intro
big_text "DR.M.AKSHITH"

# Welcome Banner
echo
echo "${COLOR_CYAN}${BOLD}┌──────────────────────────────────────────────────────────────┐${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}│              DR.M.AKSHITH - Cloud Tutorial                   │${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}└──────────────────────────────────────────────────────────────┘${COLOR_RESET}"
echo

# Enable GCP Services
echo "${COLOR_BLUE}${BOLD}⏳ Enabling Required GCP Services...${COLOR_RESET}"
echo

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  osconfig.googleapis.com \
  pubsub.googleapis.com \
  cloudaicompanion.googleapis.com

# Set Project Variables
export PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$PROJECT_ID" --format='value(project_number)')
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])" 2>/dev/null)
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])" 2>/dev/null)

if [[ -z "$REGION" ]]; then
  REGION="us-central1"
fi
if [[ -z "$ZONE" ]]; then
  ZONE="us-central1-a"
fi

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Configure IAM
SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role roles/eventarc.eventReceiver

# Update IAM Policy
gcloud projects get-iam-policy $PROJECT_ID > policy.yaml

cat <<EOF >> policy.yaml
auditConfigs:
- auditLogConfigs:
  - logType: ADMIN_READ
  - logType: DATA_READ
  - logType: DATA_WRITE
  service: compute.googleapis.com
EOF

gcloud projects set-iam-policy $PROJECT_ID policy.yaml

# Function Retry Helper
deploy_with_retry() {
  local function_name=$1
  shift
  local attempts=0
  local max_attempts=5
  
  while [ $attempts -lt $max_attempts ]; do
    echo "${COLOR_YELLOW}${BOLD}Attempt $((attempts+1)): Deploying $function_name...${COLOR_RESET}"
    
    if gcloud functions deploy $function_name "$@"; then
      echo "${COLOR_GREEN}${BOLD}✅ $function_name deployed successfully!${COLOR_RESET}"
      return 0
    else
      attempts=$((attempts+1))
      echo "${COLOR_RED}${BOLD}⚠️ Deployment failed. Retrying in 30 seconds...${COLOR_RESET}"
      sleep 30
    fi
  done
  
  echo "${COLOR_RED}${BOLD}❌ Failed to deploy $function_name after $max_attempts attempts${COLOR_RESET}"
  return 1
}

# Deploy HTTP Function
echo
echo "${COLOR_BLUE}${BOLD}🚀 Deploying HTTP Trigger Function...${COLOR_RESET}"
echo

mkdir -p ~/hello-http && cd ~/hello-http

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');

functions.http('helloWorld', (req, res) => {
  res.status(200).send('HTTP with Node.js in GCF 2nd gen!');
});
EOF

cat > package.json <<EOF
{
  "name": "nodejs-http-function",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^2.0.0"
  }
}
EOF

deploy_with_retry nodejs-http-function \
  --gen2 \
  --runtime nodejs22 \
  --entry-point helloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --timeout 600s \
  --max-instances 1 \
  --allow-unauthenticated

# Test HTTP Function
echo
echo "${COLOR_BLUE}${BOLD}🔧 Testing HTTP Function...${COLOR_RESET}"
gcloud functions call nodejs-http-function --gen2 --region $REGION

# Deploy Storage Function
echo
echo "${COLOR_BLUE}${BOLD}🚀 Deploying Storage Trigger Function...${COLOR_RESET}"
echo

mkdir -p ~/hello-storage && cd ~/hello-storage

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');

functions.cloudEvent('helloStorage', (cloudevent) => {
  console.log('Cloud Storage event with Node.js in GCF 2nd gen!');
  console.log(cloudevent);
});
EOF

cat > package.json <<EOF
{
  "name": "nodejs-storage-function",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^2.0.0"
  }
}
EOF

BUCKET="gs://gcf-gen2-storage-$PROJECT_ID"
gsutil mb -l $REGION $BUCKET 2>/dev/null

deploy_with_retry nodejs-storage-function \
  --gen2 \
  --runtime nodejs22 \
  --entry-point helloStorage \
  --source . \
  --region $REGION \
  --trigger-bucket $BUCKET \
  --trigger-location $REGION \
  --max-instances 1

# Test Storage Function
echo "Hello World" > random.txt
gsutil cp random.txt $BUCKET/random.txt

echo
echo "${COLOR_BLUE}${BOLD}📋 Checking Storage Function Logs...${COLOR_RESET}"
gcloud functions logs read nodejs-storage-function \
  --region $REGION --gen2 --limit=100 --format "value(log)"

# Deploy VM Labeler Function
echo
echo "${COLOR_BLUE}${BOLD}🚀 Deploying VM Labeler Function...${COLOR_RESET}"
echo

cd ~
rm -rf eventarc-samples
git clone https://github.com/GoogleCloudPlatform/eventarc-samples.git
cd ~/eventarc-samples/gce-vm-labeler/gcf/nodejs

deploy_with_retry gce-vm-labeler \
  --gen2 \
  --runtime nodejs22 \
  --entry-point labelVmCreation \
  --source . \
  --region $REGION \
  --trigger-event-filters="type=google.cloud.audit.log.v1.written,serviceName=compute.googleapis.com,methodName=beta.compute.instances.insert" \
  --trigger-location $REGION \
  --max-instances 1

# Create Test VM
echo
echo "${COLOR_BLUE}${BOLD}🖥️ Creating Test VM Instance...${COLOR_RESET}"
gcloud compute instances create instance-1 \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=enable-osconfig=TRUE,enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
  --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250311,mode=rw,size=10,type=pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any 2>/dev/null

# Describe VM
echo
echo "${COLOR_BLUE}${BOLD}🔍 Checking VM Details...${COLOR_RESET}"
gcloud compute instances describe instance-1 --zone $ZONE

# Deploy Colored Function
echo
echo "${COLOR_BLUE}${BOLD}🎨 Deploying Colored Hello World Function...${COLOR_RESET}"
echo

mkdir -p ~/hello-world-colored && cd ~/hello-world-colored
touch requirements.txt

cat > main.py <<EOF
import os

color = os.environ.get('COLOR')

def hello_world(request):
    return f'<body style="background-color:{color}"><h1>Hello World!</h1></body>'
EOF

deploy_with_retry hello-world-colored \
  --gen2 \
  --runtime python311 \
  --entry-point hello_world \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --update-env-vars COLOR=orange \
  --max-instances 1

# Deploy Slow Go Function
echo
echo "${COLOR_BLUE}${BOLD}🐢 Deploying Slow Go Function...${COLOR_RESET}"
echo

mkdir -p ~/min-instances && cd ~/min-instances
touch main.go

cat > main.go <<EOF
package p

import (
	"fmt"
	"net/http"
	"time"
)

func init() {
	time.Sleep(10 * time.Second)
}

func HelloWorld(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Slow HTTP Go in GCF 2nd gen!")
}
EOF

echo "module example.com/mod" > go.mod

deploy_with_retry slow-function \
  --gen2 \
  --runtime go123 \
  --entry-point HelloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --max-instances 4

# Test Slow Function
echo
echo "${COLOR_BLUE}${BOLD}🔧 Testing Slow Function...${COLOR_RESET}"
gcloud functions call slow-function --gen2 --region $REGION

# Deploy as Cloud Run Service
echo
echo "${COLOR_BLUE}${BOLD}☁️ Deploying as Cloud Run Service...${COLOR_RESET}"

export spcl_project=$(echo "$PROJECT_ID" | sed 's/-/--/g; s/$/__/g')
export my_region=$(echo "$REGION" | sed 's/-/--/g; s/$/__/g')
export full_path="$REGION-docker.pkg.dev/$PROJECT_ID/gcf-artifacts/$spcl_project$my_region"
export full_path="${full_path}slow--function:version_1"

gcloud run deploy slow-function \
--image=$full_path \
--min-instances=1 \
--max-instances=4 \
--region=$REGION \
--project=$PROJECT_ID \
--quiet

# Test Again
gcloud functions call slow-function --gen2 --region $REGION
SLOW_URL=$(gcloud functions describe slow-function --region $REGION --gen2 --format="value(serviceConfig.uri)")

# Install 'hey' load testing tool if needed
if ! command -v hey &> /dev/null; then
  sudo apt-get install -y hey -qq &> /dev/null
fi

echo
echo "${COLOR_BLUE}${BOLD}⚡ Load Testing Slow Function...${COLOR_RESET}"
hey -n 10 -c 10 $SLOW_URL

# Cleanup
echo
echo "${COLOR_BLUE}${BOLD}🧹 Cleaning Up Previous Deployment...${COLOR_RESET}"
gcloud run services delete slow-function --region $REGION --quiet

# Deploy Concurrent Function
echo
echo "${COLOR_BLUE}${BOLD}🚀 Deploying Concurrent Function...${COLOR_RESET}"

cd ~/min-instances

deploy_with_retry slow-concurrent-function \
  --gen2 \
  --runtime go123 \
  --entry-point HelloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 4

# Deploy as Cloud Run with Concurrency
export full_path="${REGION}-docker.pkg.dev/${PROJECT_ID}/gcf-artifacts/${spcl_project}${my_region}slow--concurrent--function:version_1"

gcloud run deploy slow-concurrent-function \
--image=$full_path \
--concurrency=100 \
--cpu=1 \
--max-instances=4 \
--set-env-vars=LOG_EXECUTION_ID=true \
--region=$REGION \
--project=$PROJECT_ID \
--quiet \
&& gcloud run services update-traffic slow-concurrent-function --to-latest --region=$REGION --quiet

# Final Test
SLOW_CONCURRENT_URL=$(gcloud functions describe slow-concurrent-function --region $REGION --gen2 --format="value(serviceConfig.uri)")
hey -n 10 -c 10 $SLOW_CONCURRENT_URL

# Completion Message
echo
echo "${COLOR_GREEN}${BOLD}┌──────────────────────────────────────────────────────────────┐${COLOR_RESET}"
echo "${COLOR_GREEN}${BOLD}│         LAB COMPLETED SUCCESSFULLY!                          │${COLOR_RESET}"
echo "${COLOR_GREEN}${BOLD}└──────────────────────────────────────────────────────────────┘${COLOR_RESET}"
echo
echo "${COLOR_MAGENTA}${BOLD}For more cloud computing tutorials:${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}https://youtube.com/@dr.m.akshith${COLOR_RESET}"
echo "${COLOR_MAGENTA}${BOLD}DR.M.AKSHITH - Cloud Solutions Expert${COLOR_RESET}"
echo
