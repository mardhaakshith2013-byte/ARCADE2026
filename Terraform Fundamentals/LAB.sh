#!/bin/bash

# Color definitions using tput
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)

clear
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}          Welcome to Dr. M. Akshith Tutorials!           ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}Initializing Core Lab System Variables...${RESET}"
echo

# --- 5 Second Matrix Binary Animation Loop ---
DURATION=5
START_TIME=$(date +%s)

echo "${GREEN}${BOLD}Entering Binary Verification Sequence:${RESET}"
while [ $(( $(date +%s) - START_TIME )) -lt $DURATION ]; do
    # Prints random lines of binary text to simulate verification
    for i in {1..8}; do
        printf "${GREEN}%d%d%d%d${RESET} " $((RANDOM%2)) $((RANDOM%2)) $((RANDOM%2)) $((RANDOM%2))
    done
    echo
    sleep 0.25
done

echo
echo "${YELLOW}${BOLD}Authentication Complete. Launching Cloud Script Target...${RESET}"
echo

# Download the deployment architecture script completely
curl -LO "https://raw.githubusercontent.com/NikhilVaghela0716/GCP/main/Build%20Infrastructure%20with%20Terraform%20on%20Google%20Cloud:%20Challenge%20Lab/KenilithCloudX.sh"

# Set operational run privileges
chmod +x KenilithCloudX.sh

# Pass operational context execution
./KenilithCloudX.sh
