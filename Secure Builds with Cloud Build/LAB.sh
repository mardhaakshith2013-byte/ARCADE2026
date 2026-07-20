#!/bin/bash
# ==============================================================================
# GSP1184: Secure Builds with Cloud Build
# Script provided by DR.M.AKSHITH
# ==============================================================================

set -e # Exit immediately if an unhandled command fails

# Formatting Definitions
BOLD="\033[1m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# ==============================================================================
# AKSHITH BANNER
# ==============================================================================
echo -e "${CYAN}${BOLD}"
echo "█████╗ ██╗██╗  ██╗███████╗██╗  ██╗██╗████████╗██╗  ██╗"
echo "██╔══██╗██║██║ ██╔╝██╔════╝██║  ██║██║╚══██╔══╝██║  ██║"
echo "███████║██║█████═╝ ███████╗███████║██║   ██║   ███████║"
echo "██╔══██║██║██╔═██╗ ╚════██║██╔══██║██║   ██║   ██╔══██║"
echo "██║  ██║██║██║  ██╗███████║██║  ██║██║   ██║   ██║  ██║"
echo "╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝"
echo -e "${RESET}"

echo -e "${CYAN}${BOLD}=================================================================="${RESET}
echo -e "${CYAN}${BOLD}     STARTING GSP1184 SECURE BUILDS AUTOMATION                    "${RESET}
echo -e "${CYAN}${BOLD}=================================================================="${RESET}

# ------------------------------------------------------------------------------
# Environment Setup & API Activation
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}⚙️ Setting up environment variables and active region...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
if [[ -z "$ZONE" ]]; then
    ZONE="us-central1-a"
fi
REGION=$(echo $ZONE | awk -F'-' '{print $1"-"$2}')

export ZONE
export REGION

echo -e "${YELLOW}🔑 Enabling required Google Cloud APIs...${RESET}"
gcloud services enable \
  cloudkms.googleapis.com \
  cloudbuild.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com \
  artifactregistry.googleapis.com \
  containerscanning.googleapis.com \
  ondemandscanning.googleapis.com \
  binaryauthorization.googleapis.com > /dev/null 2>&1

echo -e "${YELLOW}🔐 Granting IAM permissions for Cloud Build Service Account...${RESET}"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
        --role="roles/iam.serviceAccountUser" > /dev/null

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
        --role="roles/ondemandscanning.admin" > /dev/null

# ------------------------------------------------------------------------------
# Task 1: Build Initial Docker Application
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 1: Creating Workspace & Base Dockerfile...${RESET}"
mkdir -p vuln-scan && cd vuln-scan

cat > ./Dockerfile << 'EOF'
FROM gcr.io/google-appengine/debian11
RUN apt update && apt install python3-pip -y
WORKDIR /app
COPY . ./
RUN pip3 install Flask==1.1.4  
RUN pip3 install gunicorn==20.1.0  
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
EOF

cat > ./main.py << 'EOF'
import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    name = os.environ.get("NAME", "DR.M.AKSHITH")
    return "Hello {}!".format(name)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
EOF

cat > ./cloudbuild.yaml << EOF
steps:
- id: "build"
  name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image', '.']
  waitFor: ['-']
EOF

# ------------------------------------------------------------------------------
# Task 2: Create Artifact Registry Repository
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 2: Creating Artifact Registry Repository...${RESET}"
gcloud artifacts repositories create artifact-scanning-repo \
  --repository-format=docker \
  --location=${REGION} \
  --description="Docker repository" || true

gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

cat > ./cloudbuild.yaml << EOF
steps:
- id: "build"
  name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image', '.']
  waitFor: ['-']
- id: "push"
  name: 'gcr.io/cloud-builders/docker'
  args: ['push',  '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image']

images:
  - ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image
EOF

gcloud builds submit

# ------------------------------------------------------------------------------
# Task 4: On-Demand Local Scanning
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 4: Performing On-Demand Local Image Scan...${RESET}"
docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image .

gcloud artifacts docker images scan \
    ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image \
    --format="value(response.scan)" > scan_id.txt

cat scan_id.txt

export SEVERITY=CRITICAL
gcloud artifacts docker images list-vulnerabilities $(cat scan_id.txt) --format="value(vulnerability.effectiveSeverity)" | if grep -Fxq ${SEVERITY}; then echo "Failed vulnerability check for ${SEVERITY} level"; else echo "No ${SEVERITY} Vulnerabilities found"; fi

# ------------------------------------------------------------------------------
# Task 5: Integrate Vulnerability Scanning into CI/CD Pipeline
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 5: Updating CI/CD Pipeline & Triggering Expected Build Break...${RESET}"

cat > ./cloudbuild.yaml << EOF
steps:
- id: "build"
  name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image', '.']
  waitFor: ['-']
- id: scan
  name: 'gcr.io/cloud-builders/gcloud'
  entrypoint: 'bash'
  args:
  - '-c'
  - |
    (gcloud artifacts docker images scan \
    ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image \
    --location ${REGION} \
    --format="value(response.scan)") > /workspace/scan_id.txt
- id: severity check
  name: 'gcr.io/cloud-builders/gcloud'
  entrypoint: 'bash'
  args:
  - '-c'
  - |
      gcloud artifacts docker images list-vulnerabilities \$(cat /workspace/scan_id.txt) \
      --format="value(vulnerability.effectiveSeverity)" | if grep -Fxq CRITICAL; \
      then echo "Failed vulnerability check for CRITICAL level" && exit 1; else echo "No CRITICAL vulnerability found, congrats !" && exit 0; fi
- id: "retag"
  name: 'gcr.io/cloud-builders/docker'
  args: ['tag',  '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:good']
- id: "push"
  name: 'gcr.io/cloud-builders/docker'
  args: ['push',  '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:good']

images:
  - ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image
EOF

# Temporarily disable set -e because this build is SUPPOSED to fail (vulnerability gate test)
set +e
gcloud builds submit
set -e

# ------------------------------------------------------------------------------
# Fix Vulnerability: Replace with Clean Alpine Base Image
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Fixing Vulnerabilities: Upgrading Base Image to Clean Alpine...${RESET}"

cat > ./Dockerfile << 'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY . ./
RUN pip3 install Flask==3.0.3
RUN pip3 install gunicorn==22.0.0
RUN pip3 install Werkzeug==3.0.3
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app
EOF

echo -e "${GREEN}🚀 Running Final Clean CI/CD Build...${RESET}"
gcloud builds submit

echo -e "\n${CYAN}${BOLD}=================================================================="${RESET}
echo -e "${GREEN}${BOLD}     LAB EXECUTED SUCCESSFULLY — ALL CHECKS READY FOR 100/100!     "${RESET}
echo -e "${CYAN}${BOLD}=================================================================="${RESET}
