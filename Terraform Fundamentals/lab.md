# 🛠️ GCP Terraform Challenge Lab Automation Suite

A production-grade, end-to-end automation tool designed to systematically track, build, and standardize multi-tier cloud infrastructure configurations inside Google Cloud Platform (GCP) using modular Terraform subroutines. 

This environment automation suite is optimized for high-velocity workspace testing and sandbox verification drills (such as Google Cloud Arcade / Skills Boost Challenge Lab **GSP345**).

---

## 📘 Core Architectural Implementations

The automated engine executes standard industry-best infrastructure-as-code patterns across **11 granular orchestration phases**:

*   **State Adoption (Brownfield Imports):** Securely intercepts pre-existing, unmanaged standalone Compute Engine instances (`tf-instance-1` and `tf-instance-2`) and introduces them into the local workspace state map without causing runtime service disruptions.
*   **Infrastructure Modularity:** Deconstructs flat infrastructure architecture files into decoupled, maintainable custom modules (`modules/instances` and `modules/storage`).
*   **Remote GCS Backend Migration:** Provisions a dedicated Google Cloud Storage (GCS) block asset with explicit object locking controls to migrate operational environment states from local storage to a resilient cloud backend (`terraform/state`).
*   **Vertical & Horizontal Compute Scaling:** Manages safe compute hot-swaps, scaling legacy virtual instances from standard configurations (`n1-standard-1`) up to modern compute capacities (`e2-standard-2`).
*   **Lifecycle Engine Verification:** Exercises rapid resource provisioning and removal logic loops by dynamically building and reaping canary compute instances (`tf-instance-3`).
*   **Advanced Topography Enforcements:** Designs an isolated custom Virtual Private Cloud (`tf-vpc`) composed of segregated subnets routing through distinct regional zones, re-wires active compute network cards to the new networks, and enforces granular inbound firewall rules (`tf-firewall`) allowing secure public traffic via port 80.

---

YOUTUBE CHANEL:- https://youtube.com/@dr.m.akshith?si=SH3q4_Hz8uD-fe3-

## ⚡ Quick Start & Execution

> [!WARNING]
> 📚 **Educational & Lab Verification Use Only!**  
> This script modifies active cloud resources, sets up persistent GCS state storage, and scales instances within sandbox environments. Review all configuration arrays before utilizing inside production cloud platforms. Always follow platform Terms of Service.

Open your **Google Cloud Shell**, copy the one-click command string below, paste it directly into your terminal window, and press **Enter**:

```bash
curl -sSL [https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Build%20Infrastructure%20with%20Terraform%20on%20Google%20Cloud%3A%20Challenge%20Lab/akshith.sh](https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Build%20Infrastructure%20with%20Terraform%20on%20Google%20Cloud%3A%20Challenge%20Lab/akshith.sh) | bash
