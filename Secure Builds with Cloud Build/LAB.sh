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
# Automatic Environment & Location Detection
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}⚙️ Automatically detecting environment variables...${RESET}"

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

AUTO_REGION=$(gcloud config get-value compute/region 2>/dev/null)
AUTO_ZONE=$(gcloud config get-value compute/zone 2>/dev/null)

if [ -n "$AUTO_REGION" ]; then
    export REGION="$AUTO_REGION"
elif [ -n "$AUTO_ZONE" ]; then
    export REGION=$(echo "$AUTO_ZONE" | awk -F'-' '{print $1"-"$2}')
else
    export REGION="us-central1"
fi

SCAN_LOCATION=$(echo "$REGION" | awk -F'-' '{print $1}')
if [ "$SCAN_LOCATION" == "us" ] || [ "$SCAN_LOCATION" == "europe" ] || [ "$SCAN_LOCATION" == "asia" ]; then
    export SCAN_LOCATION="$SCAN_LOCATION"
else
    export SCAN_LOCATION="us"
fi

echo -e "${GREEN}Project ID    :${RESET} ${PROJECT_ID}"
echo -e "${GREEN}Project Number:${RESET} ${PROJECT_NUMBER}"
echo -e "${GREEN}Region        :${RESET} ${REGION}"
echo -e "${GREEN}Scan Location :${RESET} ${SCAN_LOCATION}"

# ------------------------------------------------------------------------------
# Step 1: Enable APIs and Grant IAM Permissions
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}🔑 Enabling required Google Cloud APIs...${RESET}"
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
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
        --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
        --role="roles/iam.serviceAccountUser" > /dev/null

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
        --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
        --role="roles/ondemandscanning.admin" > /dev/null

# ------------------------------------------------------------------------------
# Step 2: Create Workspace & Initial Vulnerable Application
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Creating Workspace & Base Dockerfile...${RESET}"
mkdir -p ~/vuln-scan && cd ~/vuln-scan

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

# ------------------------------------------------------------------------------
# Step 3: Create Artifact Registry & Run Initial Build
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Creating Artifact Registry Repository & Submitting Build...${RESET}"
gcloud artifacts repositories create artifact-scanning-repo \
  --repository-format=docker \
  --location="${REGION}" \
  --description="Docker repository" || true

gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

cat > ./cloudbuild.yaml << EOF
steps:
- id: "build"
  name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image', '.']
  waitFor: ['-']
- id: "push"
  name: 'gcr.io/cloud-builders/docker'
  args: ['push', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image']

images:
  - ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image
EOF

gcloud builds submit

# ------------------------------------------------------------------------------
# Step 4: Local On-Demand Scanning
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Performing On-Demand Local Image Scan (Location: ${SCAN_LOCATION})...${RESET}"
docker build -t "${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image" .

gcloud artifacts docker images scan \
    "${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image" \
    --location="${SCAN_LOCATION}" \
    --format="value(response.scan)" > scan_id.txt

cat scan_id.txt

export SEVERITY=CRITICAL
gcloud artifacts docker images list-vulnerabilities $(cat scan_id.txt) --location="${SCAN_LOCATION}" --format="value(vulnerability.effectiveSeverity)" | if grep -Fxq ${SEVERITY}; then echo "Failed vulnerability check for ${SEVERITY} level"; else echo "No ${SEVERITY} Vulnerabilities found"; fi

# ------------------------------------------------------------------------------
# Step 5: Integrate Security Gate (Build Break Test)
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Testing Security Gate (Build Break)...${RESET}"

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
    gcloud artifacts docker images scan \
    ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image \
    --location ${SCAN_LOCATION} \
    --format="value(response.scan)" > /workspace/scan_id.txt
- id: severity check
  name: 'gcr.io/cloud-builders/gcloud'
  entrypoint: 'bash'
  args:
  - '-c'
  - |
      gcloud artifacts docker images list-vulnerabilities \$(cat /workspace/scan_id.txt) --location ${SCAN_LOCATION} \
      --format="value(vulnerability.effectiveSeverity)" | if grep -Fxq CRITICAL; \
      then echo "Failed vulnerability check for CRITICAL level" && exit 1; else echo "No CRITICAL vulnerability found, congrats !" && exit 0; fi
- id: "retag"
  name: 'gcr.io/cloud-builders/docker'
  args: ['tag', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:good']
- id: "push"
  name: 'gcr.io/cloud-builders/docker'
  args: ['push', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:good']

images:
  - ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image
EOF

set +e
gcloud builds submit
set -e

# ------------------------------------------------------------------------------
# Step 6: Fix the Vulnerability (Clean Image)
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Upgrading Dockerfile to Python Alpine & Passing Security Gate...${RESET}"

cd ~/vuln-scan

cat > ./Dockerfile << 'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY . ./
RUN pip3 install Flask==3.0.3
RUN pip3 install gunicorn==22.0.0
RUN pip3 install Werkzeug==3.0.3
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app
EOF

# 1. Navigate to your workspace directory
cd ~/vuln-scan

# 2. Update Dockerfile to use clean Python Alpine image
cat > ./Dockerfile << 'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY . ./
RUN pip3 install Flask==3.0.3
RUN pip3 install gunicorn==22.0.0
RUN pip3 install Werkzeug==3.0.3
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app
EOF

# 3. Submit the final build to Cloud Build
gcloud builds submit



gcloud builds submit

echo -e "\n${CYAN}${BOLD}=================================================================="${RESET}
echo -e "${GREEN}${BOLD}     LAB EXECUTED SUCCESSFULLY — ALL CHECKS READY FOR 100/100!     "${RESET}
echo -e "${CYAN}${BOLD}=================================================================="${RESET}
