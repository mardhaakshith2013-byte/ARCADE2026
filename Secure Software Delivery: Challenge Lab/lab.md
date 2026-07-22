GSP521



# Secure Software Delivery: Challenge Lab

This lab builds a full secure CI/CD pipeline on Google Cloud — from a vulnerable image build all the way through automated scanning, signing, and a gated deployment to Cloud Run.

## What this covers

- 📦 **Artifact Registry** — separate `artifact-scanning-repo` (build/scan) and `artifact-prod-repo` (production) repositories
- 🔏 **Binary Authorization** — vulnerability attestor, Container Analysis note, and IAM bindings
- 🔑 **Cloud KMS** — asymmetric signing key linked to the attestor
- 🤖 **Secure CI/CD Pipeline** — a Cloud Build pipeline that builds, scans for vulnerabilities, blocks on CRITICAL findings, signs the image, and promotes it to the production repo
- 🚀 **Cloud Run Deployment** — deploys the signed image with Binary Authorization enforcement and public access
- 🛠️ **Review & Fix** — updates vulnerable dependencies (Flask, gunicorn, Werkzeug) and re-runs the pipeline to a clean, successful deploy

## Run it

```bash
curl -sL "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Secure%20Software%20Delivery%3A%20Challenge%20Lab/lab.sh" | bash
```

Or download and run locally:

```bash
curl -s "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Secure%20Software%20Delivery%3A%20Challenge%20Lab/lab.sh" -o lab.sh
chmod +x lab.sh
./lab.sh
```

> Requires an authenticated `gcloud` session with an active project set.

## Credits

Script by **DR.M.AKSHITH**

📺 YouTube: [@dr.m.akshith](https://youtube.com/@dr.m.akshith?si=1DgeJ7xEkfJqNXTT)
Subscribe for more Google Cloud Arcade / lab walkthroughs!
