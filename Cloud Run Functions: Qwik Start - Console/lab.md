# Cloud Run Functions: Qwik Start - Console (GSP081)

This lab creates, deploys, and tests a Cloud Run function (2nd generation) through Google Cloud — an HTTP-triggered function called `gcfunction` that returns a message, deployed with public access and a maximum of 5 instances.

## What this covers

- ⚙️ **API Enablement** — Cloud Run, Cloud Build, Artifact Registry, Eventarc, Pub/Sub
- 📦 **Function Source** — the default `helloHttp` sample (Node.js) that echoes back a `message` field
- 🚀 **Deploy** — `gcfunction` deployed via Cloud Run's unified function deploy, 2nd gen, public access, max instances = 5
- 🧪 **Test** — automatically invokes the deployed function with `{"message":"Hello World!"}` and prints the response, generating the log entry the checkpoint looks for

## Why this asks for input

Region (and sometimes the project) differ per lab session, since each Qwiklabs/Skills Boost run spins up a fresh temporary project. The script detects your current `gcloud` project/region automatically where possible and only prompts when it can't.

## Run it

```bash
curl -sL "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Cloud%20Run%20Functions%3A%20Qwik%20Start%20-%20Console/lad.sh" | bash
```

Or download and run locally:

```bash
curl -s "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Cloud%20Run%20Functions%3A%20Qwik%20Start%20-%20Console/lad.sh" -o lad.sh
chmod +x lad.sh
./lad.sh
```

> Requires an authenticated `gcloud` session (Cloud Shell in the lab works out of the box) with an active project set.

## Credits

Script by **DR.M.AKSHITH**

📺 YouTube: [@dr.m.akshith](https://youtube.com/@dr.m.akshith?si=1DgeJ7xEkfJqNXTT)
Subscribe for more Google Cloud Arcade / lab walkthroughs!
