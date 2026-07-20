# GSP1184: Secure Builds with Cloud Build
*Author/Maintainer:* **DR.M.AKSHITH**

---

## 📋 Overview

This guide walks through configuring a secure container build pipeline using **Google Cloud Build**, **Artifact Registry**, and **On-Demand Vulnerability Scanning**.

### Pipeline Objectives
1. Build a baseline container image with Python/Debian.
2. Push the baseline container to Artifact Registry.
3. Perform on-demand vulnerability scans.
4. Integrate a security gate step into `cloudbuild.yaml` to fail builds containing **CRITICAL** vulnerabilities.
5. Upgrade to a hardened `python:3.12-alpine` base image to pass the vulnerability gate.

---

## ⚡ Quick One-Line Automated Setup

To run the complete lab end-to-end (including handling the intentional build break step), execute this command in your Cloud Shell:

```bash
curl -LO raw.githubusercontent.com/QUICK-GCP-LAB/2-Minutes-Labs-Solutions/refs/heads/main/Secure%20Builds%20with%20Cloud%20Build/gsp1184.sh
chmod +x gsp1184.sh
./gsp1184.sh
