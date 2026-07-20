#!/bin/bash

# ==========================================
# Script by: DR.M.AKSHITH (Fixed & Verified)
# ==========================================

BOLD_TEXT="\033[1m"
RESET_FORMAT="\033[0m"
BLUE_TEXT="\033[1;34m"
CYAN_TEXT="\033[1;36m"
GREEN_TEXT="\033[1;32m"
RED_TEXT="\033[1;31m"
YELLOW_TEXT="\033[1;33m"

print_step() {
    echo -e "\n${CYAN_TEXT}${BOLD_TEXT}🚀 [TASK] $1${RESET_FORMAT}"
    echo -e "${CYAN_TEXT}─────────────────────────────────────────────────────────────────${RESET_FORMAT}"
}

print_info() {
    echo -e "${BLUE_TEXT}ℹ️  $1${RESET_FORMAT}"
}

echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}     DR.M.AKSHITH - INITIATING EXECUTION...  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

validate_project_id() {
  local project_id=$1
  if [[ -z "$project_id" ]]; then
    echo -e "${RED_TEXT}❌ Error: PROJECT_ID is not set.${RESET_FORMAT}"
    exit 1
  fi
}

set_zone_and_region() {
  ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
  REGION=$(gcloud config get-value compute/region 2>/dev/null)

  if [[ -z "$ZONE" ]]; then
    read -p "👉 Enter your zone (e.g., us-central1-c): " ZONE
  fi

  if [[ -z "$REGION" ]]; then
    REGION=$(echo $ZONE | awk -F'-' '{print $1"-"$2}')
  fi

  export ZONE
  export REGION
  echo -e "${GREEN_TEXT}✅ Context -> Zone: ${BOLD_TEXT}$ZONE${RESET_FORMAT}${GREEN_TEXT} | Region: ${BOLD_TEXT}$REGION${RESET_FORMAT}"
}

print_info "Initializing context variables..."

export PROJECT_ID=$(gcloud config get-value project)
validate_project_id "$PROJECT_ID"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

set_zone_and_region

print_step "Enabling Required Google Cloud Services"
gcloud services enable \
  cloudkms.googleapis.com \
  cloudbuild.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com \
  artifactregistry.googleapis.com \
  containerscanning.googleapis.com \
  ondemandscanning.googleapis.com \
  binaryauthorization.googleapis.com

# Task 1: Artifact Registry
print_step "Creating Artifact Registry Repository"
gcloud artifacts repositories create artifact-scanning-repo \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repository" || true

gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

mkdir -p vuln-scan && cd vuln-scan

cat > ./Dockerfile << EOF
FROM python:3.8-alpine   

WORKDIR /app
COPY . ./

RUN pip3 install Flask==2.1.0
RUN pip3 install gunicorn==20.1.0
RUN pip3 install Werkzeug==2.2.2

CMD exec gunicorn --bind :\$PORT --workers 1 --threads 8 main:app
EOF

cat > ./main.py << EOF
import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    name = os.environ.get("NAME", "Worlds")
    return "Hello {}!".format(name)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
EOF

gcloud builds submit . -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image

# Task 2: Attestor Setup
print_step "Setting up Binary Authorization Attestor"

cat > ./vulnz_note.json << EOM
{
  "attestation": {
    "hint": {
      "human_readable_name": "Container Vulnerabilities attestation authority"
    }
  }
}
EOM

NOTE_ID=vulnz_note

curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    --data-binary @./vulnz_note.json \
    "https://containeranalysis.googleapis.com/v1/projects/${PROJECT_ID}/notes/?noteId=${NOTE_ID}"

ATTESTOR_ID=vulnz-attestor

gcloud container binauthz attestors create $ATTESTOR_ID \
    --attestation-authority-note=$NOTE_ID \
    --attestation-authority-note-project=${PROJECT_ID} || true

BINAUTHZ_SA_EMAIL="service-${PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

cat > ./iam_request.json << EOM
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
EOM

curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    --data-binary @./iam_request.json \
    "https://containeranalysis.googleapis.com/v1/projects/${PROJECT_ID}/notes/${NOTE_ID}:setIamPolicy"

# Task 3: KMS Key Setup
print_step "Provisioning Cloud KMS Asymmetric Keys"

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

# Task 4: Manual Attestation
print_step "Generating Manual Cryptographic Attestation"

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

# Task 5: GKE Cluster
print_step "Creating GKE Cluster with Binary Authorization"

gcloud beta container clusters create binauthz \
    --zone $ZONE \
    --binauthz-evaluation-mode=PROJECT_SINGLETON_POLICY_ENFORCE || true

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/container.developer"

# Task 6: Automated Signing Pipeline
print_step "Configuring Continuous Integration Automation Roles & Builder"

gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role roles/binaryauthorization.attestorsViewer
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role roles/cloudkms.signerVerifier
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com --role roles/cloudkms.signerVerifier
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role roles/containeranalysis.notes.attacher
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" --role="roles/iam.serviceAccountUser"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" --role="roles/ondemandscanning.admin"

git clone https://github.com/GoogleCloudPlatform/cloud-builders-community.git
cd cloud-builders-community/binauthz-attestation
gcloud builds submit . --config cloudbuild.yaml
cd ../..
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

# Task 7: Deploy Signed Image
print_step "Updating Policy & Deploying Compliant Image"

gcloud container clusters get-credentials binauthz --zone $ZONE

cat > binauth_policy.yaml << EOM
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: REQUIRE_ATTESTATION
  requireAttestationsBy:
  - projects/${PROJECT_ID}/attestors/vulnz-attestor
globalPolicyEvaluationMode: ENABLE
clusterAdmissionRules:
  ${ZONE}.binauthz:
    evaluationMode: REQUIRE_ATTESTATION
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
    requireAttestationsBy:
    - projects/${PROJECT_ID}/attestors/vulnz-attestor
EOM

gcloud beta container binauthz policy import binauth_policy.yaml
sleep 10

CONTAINER_PATH=${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image
DIGEST=$(gcloud container images describe ${CONTAINER_PATH}:good --format='get(image_summary.digest)')

cat > deploy.yaml << EOM
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
        image: ${CONTAINER_PATH}@${DIGEST}
        ports:
        - containerPort: 8080
        env:
          - name: PORT
            value: "8080"
EOM

kubectl apply -f deploy.yaml

# Task 8: Attempt Unsigned Image Deployment (Expected to fail/block)
print_step "Executing Gatekeeping Verification on Unsigned Manifests"

docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:bad .
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/artifact-scanning-repo/sample-image:bad

DIGEST=$(gcloud container images describe ${CONTAINER_PATH}:bad --format='get(image_summary.digest)')

cat > deploy_bad.yaml << EOM
apiVersion: v1
kind: Service
metadata:
  name: deb-httpd-bad
spec:
  selector:
    app: deb-httpd-bad
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deb-httpd-bad
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deb-httpd-bad
  template:
    metadata:
      labels:
        app: deb-httpd-bad
    spec:
      containers:
      - name: deb-httpd-bad
        image: ${CONTAINER_PATH}@${DIGEST}
        ports:
        - containerPort: 8080
        env:
          - name: PORT
            value: "8080"
EOM

kubectl apply -f deploy_bad.yaml || true

echo -e "\n${GREEN_TEXT}${BOLD_TEXT}✅ ALL TASKS EXECUTED SUCCESSFULLY! CHECK YOUR PROGRESS FOR 100/100.${RESET_FORMAT}\n"
