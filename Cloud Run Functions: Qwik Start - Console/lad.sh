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

echo "${CYAN}${BOLD}==================================================================${RESET}"
echo "${CYAN}${BOLD}      DR.M.AKSHITH - GSP081: Cloud Run Functions Qwik Start      ${RESET}"
echo "${CYAN}${BOLD}==================================================================${RESET}"
echo

# ---------- Gather details (varies per user/lab session) ----------
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "$PROJECT_ID" ]]; then
  read -p "👉 Enter your PROJECT_ID: " PROJECT_ID
  export PROJECT_ID
fi
echo "${GREEN}✅ Project: ${BOLD}$PROJECT_ID${RESET}"

DEFAULT_REGION=$(gcloud config get-value compute/region 2>/dev/null)
if [[ -n "$DEFAULT_REGION" ]]; then
  read -p "👉 Enter REGION [default: $DEFAULT_REGION]: " REGION
  REGION=${REGION:-$DEFAULT_REGION}
else
  read -p "👉 Enter REGION for this lab (e.g. us-central1): " REGION
fi
export REGION
echo "${GREEN}✅ Region: ${BOLD}$REGION${RESET}"
echo

# ---------- Enable required APIs ----------
echo "${YELLOW}⚙️  Enabling required APIs (run, build, artifact registry, eventarc)...${RESET}"
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

# ---------- Task 1 & 2: Create + deploy the function ----------
echo "${YELLOW}📦 Preparing function source (gcfunction, default helloHttp sample)...${RESET}"
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

echo "${GREEN}✅ Source ready!${RESET}"
echo

echo "${YELLOW}🚀 Deploying gcfunction to Cloud Run (2nd gen, public, max-instances=5)...${RESET}"
gcloud run deploy gcfunction \
  --source=. \
  --function=helloHttp \
  --region="$REGION" \
  --allow-unauthenticated \
  --max-instances=5 \
  --project="$PROJECT_ID"

if [[ $? -ne 0 ]]; then
  echo "${RED}❌ Deploy failed — scroll up for the error and re-run this script.${RESET}"
  exit 1
fi
echo "${GREEN}✅ Task 1 + 2 complete: function created and deployed.${RESET}"
echo

# ---------- Task 3: Test the function ----------
echo "${YELLOW}🧪 Testing the function with a sample invocation...${RESET}"
FUNCTION_URL=$(gcloud run services describe gcfunction --region="$REGION" --project="$PROJECT_ID" --format='value(status.url)')

echo "${CYAN}Function URL: $FUNCTION_URL${RESET}"

RESPONSE=$(curl -s -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello World!"}')

echo "${GREEN}Response: ${BOLD}$RESPONSE${RESET}"
echo "${GREEN}✅ Task 3 complete: function tested — check log entries under Observability > Logs.${RESET}"
echo

cd ..

echo "${CYAN}${BOLD}=======================================================${RESET}"
echo "${CYAN}${BOLD}              LAB COMPLETED SUCCESSFULLY!              ${RESET}"
echo "${CYAN}${BOLD}=======================================================${RESET}"
echo
echo "${GREEN}${BOLD}Script by DR.M.AKSHITH${RESET}"
echo "${GREEN}${BOLD}YouTube: https://youtube.com/@dr.m.akshith${RESET}"
echo
echo "${YELLOW}Now go click 'Check my progress' on both checkpoints in the lab page.${RESET}"
