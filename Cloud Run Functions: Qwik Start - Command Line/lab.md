# Cloud Run Functions: Qwik Start - Command Line

A tour through Cloud Run functions (2nd gen) using the `gcloud` CLI end-to-end — HTTP triggers, storage triggers, Eventarc audit-log triggers, scaling behavior (min/max instances, concurrency), and deploying functions as full Cloud Run services.

## What this covers

- ⚙️ **API Enablement** — Artifact Registry, Cloud Functions, Cloud Build, Eventarc, Cloud Run, Pub/Sub, and more
- 🚀 **HTTP Function** — `nodejs-http-function`, a basic Node.js 22 HTTP-triggered function
- 🪣 **Storage Trigger Function** — `nodejs-storage-function`, fires on object uploads to a GCS bucket
- 🖥️ **Eventarc Audit-Log Trigger** — `gce-vm-labeler`, auto-labels a VM the moment it's created
- 🎨 **Env Vars** — a colored "Hello World" Python function driven by an environment variable
- 🐢 **Cold Starts vs Min Instances** — a deliberately slow Go function, tested first cold, then with `min-instances` and Cloud Run concurrency settings to show the performance difference
- ⚡ **Load Testing** — uses `hey` to compare latency before/after scaling configuration
- ✅ **Progress Checkpoint** — pauses mid-script so you can verify Task 6 in the lab UI before continuing

## Run it

```bash
curl -sL "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Cloud%20Run%20Functions%3A%20Qwik%20Start%20-%20Command%20Line/lab.sh" | bash
```

Or download and run locally:

```bash
curl -s "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Cloud%20Run%20Functions%3A%20Qwik%20Start%20-%20Command%20Line/lab.sh" -o lab.sh
chmod +x lab.sh
./lab.sh
```

> Requires an authenticated `gcloud` session (Cloud Shell in the lab works out of the box) with an active project set. The script pauses partway through and asks you to confirm Task 6 is verified before it continues.

## Credits

Script by **DR.M.AKSHITH**

📺 YouTube: [@dr.m.akshith](https://youtube.com/@dr.m.akshith?si=1DgeJ7xEkfJqNXTT)
Subscribe for more Google Cloud Arcade / lab walkthroughs!
