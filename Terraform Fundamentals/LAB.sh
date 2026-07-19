cat << 'EOF' > run_lab.sh
#!/bin/bash
clear
echo "╔════════════════════════════════════════════════════════╗"
echo "          Welcome to Dr. M. Akshith Tutorials!           "
echo "╚════════════════════════════════════════════════════════╝"
echo
echo "Initializing Core Lab System Variables..."
echo
DURATION=5
START_TIME=$(date +%s)
echo "Entering Binary Verification Sequence:"
while [ $(( $(date +%s) - START_TIME )) -lt $DURATION ]; do
    for i in {1..8}; do
        printf "%d%d%d%d " $((RANDOM%2)) $((RANDOM%2)) $((RANDOM%2)) $((RANDOM%2))
    done
    echo
    sleep 0.25
done
echo
echo "Authentication Complete. Launching Cloud Script Target..."
echo

# Downloads the main lab script with correct URL spacing (%20)
curl -LO "https://raw.githubusercontent.com/NikhilVaghela0716/GCP/main/Build%20Infrastructure%20with%20Terraform%20on%20Google%20Cloud:%20Challenge%20Lab/DR.M.AKSHITH.sh"
chmod +x DR.M.AKSHITH.sh
./DR.M.AKSHITH.sh
EOF

chmod +x run_lab.sh
./run_lab.sh
