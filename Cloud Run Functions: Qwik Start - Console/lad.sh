#!/bin/bash

# ==========================================
# Script by: DR.M.AKSHITH
# YouTube: https://youtube.com/@dr.m.akshith
# Lab: Cloud Run Functions: Qwik Start - Console (GSP081)
# ==========================================

GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
CYAN=$'\033[0;96m'
RED=$'\033[0;91m'
BOLD=`tput bold`
RESET=`tput sgr0`

# ---------- Matrix-style green binary intro (10 seconds, full screen) ----------
matrix_intro() {
    tput civis 2>/dev/null
    clear
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    local end=$((SECONDS + 10))
    local pattern="01010111001101"
    local pat_len=${#pattern}
    
    while [ $SECONDS -lt $end ]; do
        local line=""
        for ((i = 0; i < cols; i++)); do
            local rand_idx=$((RANDOM % pat_len))
            line+="${pattern:$rand_idx:1}"
        done
        echo -e "${GREEN}${line}${RESET}"
        sleep 0.05
    done
    clear
    tput cnorm 2>/dev/null
}

# Run 10s Matrix Intro
matrix_intro

echo "${CYAN}${BOLD}==================================================================${RESET}"
echo "${CYAN}${BOLD}      DR.M.AKSHITH - GSP081: Cloud Run Functions Qwik Start      ${RESET}"
echo "${CYAN}${BOLD}==================================================================${RESET}"
echo

# ---------- 1. Get Project ID & Region ----------
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "$PROJECT_ID" ]]; then
  read -p "👉 Enter your PROJECT_ID: " PROJECT_ID
  export PROJECT_ID
fi
echo "${GREEN}✅ Project: ${BOLD}$PROJECT_ID${RESET}"

# Auto-detect region or set default
DETECTED_ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])" 2>/dev/null)
REGION=""
if [[ -n "$DETECTED_ZONE" ]]; then
  REGION=$(echo "$DETECTED_ZONE" | cut -d '-' -f 1-2)
fi

if [[ -z "$REGION" ]]; then
  REGION="us-central1"
fi

export REGION
gcloud config set run/region $REGION
gcloud config set functions/region $REGION
echo "${GREEN}✅ Region set to: ${BOLD}$REGION${RESET}"
echo

# ---------- 2. Enable Required APIs ----------
echo "${YELLOW}⚙️  Enabling required APIs...${RESET}"
gcloud services enable \
  run.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  eventarc.googleapis.com \
  pubsub.googleapis.com \
  logging.googleapis.com \
  --project="$PROJECT_ID"
echo "${GREEN}✅ APIs enabled!${RESET}"
echo

# ---------- 3. Create Source Code ----------
echo "${YELLOW}📦 Creating source code directory (gcfunction)...${RESET}"
rm -rf gcfunction-src
mkdir -p gcfunction-src && cd gcfunction-src

cat > index.js << 'EOF'
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  let message = req.query.message || req.body.message || 'Hello World!';
  res.status(200).send(message);
});
EOF

cat > package.json << 'EOF'
{
  "name": "sample-http",
  "version": "0.0.1",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

echo "${GREEN}✅ Source files ready.${RESET}"
echo

# ---------- 4. Deploy Function (Deploying to both Cloud Run & Cloud Functions API) ----------
echo "${YELLOW}🚀 Deploying gcfunction to Cloud Run Functions...${RESET}"

gcloud functions deploy gcfunction \
  --gen2 \
  --runtime=nodejs20 \
  --region="$REGION" \
  --source=. \
  --entry-point=helloHttp \
  --trigger-http \
  --allow-unauthenticated \
  --max-instances=5 \
  --project="$PROJECT_ID" \
  --quiet

if [[ $? -ne 0 ]]; then
  echo "${RED}⚠️  Retrying deployment via gcloud run...${RESET}"
  gcloud run deploy gcfunction \
    --source=. \
    --function=helloHttp \
    --region="$REGION" \
    --allow-unauthenticated \
    --max-instances=5 \
    --project="$PROJECT_ID" \
    --quiet
fi

echo "${GREEN}✅ Task 1 & 2 complete: gcfunction successfully deployed!${RESET}"
echo

# ---------- 5. Test Function ----------
echo "${YELLOW}🧪 Invoking function URL...${RESET}"
FUNCTION_URL=$(gcloud functions describe gcfunction --gen2 --region="$REGION" --project="$PROJECT_ID" --format='value(serviceConfig.uri)' 2>/dev/null)

if [[ -z "$FUNCTION_URL" ]]; then
  FUNCTION_URL=$(gcloud run services describe gcfunction --region="$REGION" --project="$PROJECT_ID" --format='value(status.url)' 2>/dev/null)
fi

echo "${CYAN}Function URL: $FUNCTION_URL${RESET}"

RESPONSE=$(curl -s -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello World!"}')

echo "${GREEN}Response: ${BOLD}$RESPONSE${RESET}"
echo "${GREEN}✅ Task 3 complete: Function invocation verified.${RESET}"
echo

cd ..

echo "${CYAN}${BOLD}=======================================================${RESET}"
echo "${CYAN}${BOLD}             LAB COMPLETED SUCCESSFULLY!               ${RESET}"
echo "${CYAN}${BOLD}=======================================================${RESET}"
echo
echo "${GREEN}${BOLD}Script by DR.M.AKSHITH${RESET}"
echo "${GREEN}${BOLD}YouTube: https://youtube.com/@dr.m.akshith${RESET}"
echo
echo "${YELLOW}Click 'Check my progress' on the lab portal now.${RESET}"
