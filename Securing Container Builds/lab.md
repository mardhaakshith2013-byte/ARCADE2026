# Securing Container Builds

This lab covers how to secure your software supply chain using **Google Artifact Registry**'s different repository modes — standard, remote, and virtual — to manage Java (Maven) packages safely and efficiently.

## What this covers

- 📦 **Standard Repository** — create `container-dev-java-repo` to store your own private Maven packages
- 🌐 **Remote Repository** — set up `maven-central-cache` to cache third-party packages from Maven Central, improving reliability and build speed
- 🔗 **Virtual Repository** — combine the standard and remote repos into a single `virtual-maven-repo` endpoint via an upstream policy, so consumers only need one repository URL
- 🛡️ Reduces exposure to dependency confusion attacks by controlling exactly which upstream sources are trusted

## Run it

```bash
curl -sL "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Securing%20Container%20Builds/lab.sh" | bash
```

Or download and run locally:

```bash
curl -s "https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Securing%20Container%20Builds/lab.sh" -o lab.sh
chmod +x lab.sh
./lab.sh
```

> Requires an authenticated `gcloud` session with an active project set.

## Credits

Script by **DR.M.AKSHITH**

📺 YouTube: [@dr.m.akshith](https://youtube.com/@dr.m.akshith?si=1DgeJ7xEkfJqNXTT)
Subscribe for more Google Cloud Arcade / lab walkthroughs!
