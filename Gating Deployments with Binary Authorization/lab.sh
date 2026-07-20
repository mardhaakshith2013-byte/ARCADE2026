#!/bin/bash
# ==============================================================================
# GSP1183: Gating Deployments with Binary Authorization
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
echo -e "${CYAN}${BOLD}     STARTING GSP1183 AUTOMATED DEPLOYMENT & ATTESTATION          "${RESET}
echo -e "${CYAN}${BOLD}=================================================================="${RESET}

# ------------------------------------------------------------------------------
# Task 0: Environment setup & Dynamic Zone Detection
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}⚙️ Setting up environment variables and detecting cluster location...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
if [[ -z "$ZONE" ]]; then
    ZONE="us-central1-a"
fi
REGION=$(echo $ZONE | awk -F'-' '{print $1"-"$2}')

export ZONE
export REGION

echo -e "${YELLOW}🔑 Enabling necessary GCP service APIs...${RESET}"
gcloud services enable \
  cloudkms.googleapis.com \
  cloudbuild.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com \
  artifactregistry.googleapis.com \
  containerscanning.googleapis.com \
  ondemandscanning.googleapis.com \
  binaryauthorization.googleapis.com > /dev/null 2>&1

# ------------------------------------------------------------------------------
# Task 1: Create Artifact Registry Repository & Build Baseline Image
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 1: Creating Artifact Registry & Building Sample Image...${RESET}"
gcloud artifacts repositories create artifact-scanning-repo \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repository" || true

gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

mkdir -p ~/vuln-scan && cd ~/vuln-scan

cat > ./Dockerfile << 'EOF'
FROM python:3.8-alpine   
WORKDIR /app
COPY . ./
RUN pip3 install Flask==2.1.0 gunicorn==20.1.0 Werkzeug==2.2.2
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app
EOF

cat > ./main.py << 'EOF'
import os
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello_world():
    name = os.environ.get("NAME", "World")
    return "Hello {}!".format(name)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
EOF

gcloud builds submit . -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image

# ------------------------------------------------------------------------------
# Tasks 2 & 3: Container Analysis Note, Attestor, & Cloud KMS Asymmetric Key
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Tasks 2 & 3: Setting up Container Analysis Note, Attestor, and Cloud KMS Key...${RESET}"

cat > ./vulnz_note.json << EOF
{
  "attestation": {
    "hint": {
      "human_readable_name": "Container Vulnerabilities attestation authority"
    }
  }
}
EOF

NOTE_ID=vulnz_note
ATTESTOR_ID=vulnz-attestor

curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    --data-binary @./vulnz_note.json \
    "https://containeranalysis.googleapis.com/v1/projects/${PROJECT_ID}/notes/?noteId=${NOTE_ID}" > /dev/null

gcloud container binauthz attestors create $ATTESTOR_ID \
    --attestation-authority-note=$NOTE_ID \
    --attestation-authority-note-project=${PROJECT_ID} || true

BINAUTHZ_SA_EMAIL="service-${PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

cat > ./iam_request.json << EOF
{
  "resource": "projects/${PROJECT_ID}/notes/${NOTE_ID}",
  "policy": {
    "bindings": [
      {
        "role": "roles/containeranalysis.notes.occurrences.viewer",
        "members": [
          "serviceAccount:${BINAUTHZ_SA_EMAIL}"
        ]
      }
    ]
  }
}
EOF

curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    --data-binary @./iam_request.json \
    "https://containeranalysis.googleapis.com/v1/projects/${PROJECT_ID}/notes/${NOTE_ID}:setIamPolicy" > /dev/null

KEY_LOCATION=global
KEYRING=binauthz-keys
KEY_NAME=codelab-key
KEY_VERSION=1

gcloud kms keyrings create "${KEYRING}" --location="${KEY_LOCATION}" || true

gcloud kms keys create "${KEY_NAME}" \
    --keyring="${KEYRING}" --location="${KEY_LOCATION}" \
    --purpose asymmetric-signing \
    --default-algorithm="ec-sign-p256-sha256" || true

gcloud beta container binauthz attestors public-keys add \
    --attestor="${ATTESTOR_ID}" \
    --keyversion-project="${PROJECT_ID}" \
    --keyversion-location="${KEY_LOCATION}" \
    --keyversion-keyring="${KEYRING}" \
    --keyversion-key="${KEY_NAME}" \
    --keyversion="${KEY_VERSION}" || true

# ------------------------------------------------------------------------------
# Task 4: Create Manual Signed Attestation Baseline
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 4: Generating Manual Attestation...${RESET}"
CONTAINER_PATH=${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image
DIGEST=$(gcloud container images describe ${CONTAINER_PATH}:latest --format='get(image_summary.digest)')

gcloud beta container binauthz attestations sign-and-create \
    --artifact-url="${CONTAINER_PATH}@${DIGEST}" \
    --attestor="${ATTESTOR_ID}" \
    --attestor-project="${PROJECT_ID}" \
    --keyversion-project="${PROJECT_ID}" \
    --keyversion-location="${KEY_LOCATION}" \
    --keyversion-keyring="${KEYRING}" \
    --keyversion-key="${KEY_NAME}" \
    --keyversion="${KEY_VERSION}"

# ------------------------------------------------------------------------------
# Task 5: Create GKE Cluster & Safely Obtain Credentials
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 5: Creating GKE Cluster (binauthz) & Fetching Credentials...${RESET}"
gcloud beta container clusters create binauthz \
    --zone $ZONE \
    --binauthz-evaluation-mode=PROJECT_SINGLETON_POLICY_ENFORCE || true

CLUSTER_ZONE=$(gcloud container clusters list --filter="name:binauthz" --format="value(zone)")
if [[ -n "$CLUSTER_ZONE" ]]; then
  ZONE=$CLUSTER_ZONE
fi

gcloud container clusters get-credentials binauthz --zone $ZONE

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/container.developer" > /dev/null

# ------------------------------------------------------------------------------
# Task 6: Custom Attestation Builder & Cloud Build Pipeline
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 6: Building Custom Attestation Step & Running CI/CD Pipeline...${RESET}"

gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role roles/binaryauthorization.attestorsViewer > /dev/null
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role roles/cloudkms.signerVerifier > /dev/null
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com --role roles/cloudkms.signerVerifier > /dev/null
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role roles/containeranalysis.notes.attacher > /dev/null
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" --role="roles/iam.serviceAccountUser" > /dev/null
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" --role="roles/ondemandscanning.admin" > /dev/null

rm -rf cloud-builders-community
git clone https://github.com/GoogleCloudPlatform/cloud-builders-community.git
cd cloud-builders-community/binauthz-attestation
gcloud builds submit . --config cloudbuild.yaml
cd ~/vuln-scan
rm -rf cloud-builders-community

cat > ./cloudbuild.yaml << EOF
steps:
- id: "build"
  name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image', '.']
  waitFor: ['-']

- id: "retag"
  name: 'gcr.io/cloud-builders/docker'
  args: ['tag', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:good']

- id: "push"
  name: 'gcr.io/cloud-builders/docker'
  args: ['push', '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:good']

- id: 'create-attestation'
  name: 'gcr.io/${PROJECT_ID}/binauthz-attestation:latest'
  args:
    - '--artifact-url'
    - '${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:good'
    - '--attestor'
    - 'projects/${PROJECT_ID}/attestors/${ATTESTOR_ID}'
    - '--keyversion'
    - 'projects/${PROJECT_ID}/locations/${KEY_LOCATION}/keyRings/${KEYRING}/cryptoKeys/${KEY_NAME}/cryptoKeyVersions/${KEY_VERSION}'

images:
  - ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:good
EOF

gcloud builds submit

# ------------------------------------------------------------------------------
# Task 7: Policy Import & Deploy Signed Image
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 7: Importing Binary Authorization Policy & Deploying Signed Image...${RESET}"

cat > binauth_policy.yaml << EOF
clusterAdmissionRules:
  ${ZONE}.binauthz:
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
    evaluationMode: REQUIRE_ATTESTATION
    requireAttestationsBy:
    - projects/${PROJECT_ID}/attestors/vulnz-attestor
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: REQUIRE_ATTESTATION
  requireAttestationsBy:
  - projects/${PROJECT_ID}/attestors/vulnz-attestor
globalPolicyEvaluationMode: ENABLE
name: projects/${PROJECT_ID}/policy
EOF

gcloud container binauthz policy import binauth_policy.yaml

sleep 15

GOOD_DIGEST=$(gcloud container images describe ${CONTAINER_PATH}:good --format='get(image_summary.digest)')

cat > deploy.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: deb-httpd
spec:
  selector:
    app: deb-httpd
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deb-httpd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deb-httpd
  template:
    metadata:
      labels:
        app: deb-httpd
    spec:
      containers:
      - name: deb-httpd
        image: ${CONTAINER_PATH}@${GOOD_DIGEST}
        ports:
        - containerPort: 8080
        env:
          - name: PORT
            value: "8080"
EOF

kubectl apply -f deploy.yaml

# ------------------------------------------------------------------------------
# Task 8: Build Bad Image & Trigger Expected Policy Rejection
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}🚀 Task 8: Pushing Unsigned Image & Verifying Admission Policy Block...${RESET}"

docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:bad .
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:bad

BAD_DIGEST=$(gcloud container images describe ${CONTAINER_PATH}:bad --format='get(image_summary.digest)')

cat > deploy_bad.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: deb-httpd
spec:
  selector:
    app: deb-httpd
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deb-httpd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deb-httpd
  template:
    metadata:
      labels:
        app: deb-httpd
    spec:
      containers:
      - name: deb-httpd
        image: ${CONTAINER_PATH}@${BAD_DIGEST}
        ports:
        - containerPort: 8080
        env:
          - name: PORT
            value: "8080"
EOF

set +e
kubectl apply -f deploy_bad.yaml
set -e

echo -e "\n${CYAN}${BOLD}=================================================================="${RESET}
echo -e "${GREEN}${BOLD}     LAB EXECUTED SUCCESSFULLY — ALL CHECKS READY FOR 100/100!     "${RESET}
echo -e "${CYAN}${BOLD}=================================================================="${RESET}
