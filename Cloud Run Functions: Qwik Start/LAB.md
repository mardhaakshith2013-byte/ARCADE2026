# Cloud Run Functions: Qwik Start (GSP1089)

⚠️ **Status: template only.** This script currently contains the setup/branding skeleton (region detection, API enablement, intro animation, completion banner) but not yet the actual GSP1089 task commands. The "Running automation tasks..." line is a placeholder — replace it with the real deploy/test steps for this lab before running it end-to-end.

## What's in the script right now

- 🟩 5-second green binary intro animation
- 🌍 Auto-detects region from `gcloud config`, falls back to `us-central1`
- ⚙️ Enables Artifact Registry, Cloud Functions, Cloud Build, Cloud Run, and Logging APIs
- 🏁 Branded completion banner naming the lab

## What's still missing

- The actual GSP1089 steps: creating and deploying the Cloud Run function, setting the trigger, testing it

## Run it

```bash
curl -sL "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Cloud%20Run%20Functions%3A%20Qwik%20Start/LAB.sh" | bash
```

Or download and run locally:

```bash
curl -s "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Cloud%20Run%20Functions%3A%20Qwik%20Start/LAB.sh" -o LAB.sh
chmod +x LAB.sh
./LAB.sh
```

> Requires an authenticated `gcloud` session with an active project set. As-is, it'll enable APIs and print the banners, but won't deploy anything yet.

## Credits

Script by **DR.M.AKSHITH**

📺 YouTube: [@dr.m.akshith](https://youtube.com/@dr.m.akshith?si=1DgeJ7xEkfJqNXTT)
Subscribe for more Google Cloud Arcade / lab walkthroughs!
