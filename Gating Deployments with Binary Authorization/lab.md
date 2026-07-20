# Gating Deployments with Binary Authorization

This lab walks through securing a GKE deployment pipeline end-to-end using **Google Cloud Binary Authorization** — ensuring only vulnerability-scanned, cryptographically attested container images can ever reach your cluster.

## What this covers

- 📦 **Artifact Registry** — build and push a sample Flask app image with Cloud Build
- 🔏 **Attestors & Notes** — set up a Container Analysis note and a Binary Authorization attestor
- 🔑 **Cloud KMS** — generate an asymmetric signing key and attach it to the attestor
- ✍️ **Manual Attestation** — sign an image digest and verify the attestation
- 🚪 **Admission Control** — deploy a GKE cluster in `PROJECT_SINGLETON_POLICY_ENFORCE` mode
- 🤖 **CI/CD Automation** — auto-sign images on push using a custom Cloud Build step
- ✅ **Policy Enforcement** — deploy an attested "good" image successfully
- ⛔ **Gatekeeping in Action** — watch an unattested "bad" image get blocked at admission

## Run it

```bash
curl -sL "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Gating%20Deployments%20with%20Binary%20Authorization/lab.sh" | bash
```

Or download and run locally:

```bash
curl -s "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Gating%20Deployments%20with%20Binary%20Authorization/lab.sh" -o lab.sh
chmod +x lab.sh
./lab.sh
```

> Requires an authenticated `gcloud` session with an active project set.

## Credits

Script by **DR.M.AKSHITH**

📺 YouTube: [@dr.m.akshith](https://youtube.com/@dr.m.akshith?si=1DgeJ7xEkfJqNXTT)
Subscribe for more Google Cloud Arcade / lab walkthroughs!
