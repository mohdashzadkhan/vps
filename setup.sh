#!/bin/bash
# A robust script to set up a VPS with essential recon tools.
# This script is designed to be run from anywhere, as it automatically
# detects its own location to find necessary configuration files.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Automatically find the script's own directory ---
# This allows the script to be run from any location on the system.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "================================================================="
echo "            VPS Recon Tools Auto-Installer"
echo "================================================================="
echo "[*] Script is running from: $SCRIPT_DIR"
echo

# --- System Update and Dependencies ---
echo "[+] Updating system packages and installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y git curl wget unzip make build-essential python3-pip
echo "[✔] Dependencies installed."
echo

# --- Go Language Installation ---
GO_VERSION="1.22.3" # You can update this version number as needed
echo "[+] Installing Go (Version $GO_VERSION)..."
if [ -d "/usr/local/go" ]; then
    echo "[!] Go is already installed. Skipping."
else
    cd /tmp
    wget -q https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
    rm go$GO_VERSION.linux-amd64.tar.gz
    echo "[✔] Go installed successfully."
fi
# Set Go environment variables for the current session and for future sessions
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
echo

# --- Tool Installation ---
echo "[+] Installing recon tools..."

echo "  [-] Installing massdns..."
cd ~
if [ -d "massdns" ]; then
    echo "[!] massdns directory already exists. Skipping clone."
else
    git clone https://github.com/blechschmidt/massdns.git
fi
cd massdns && make && sudo make install
cd ~ # Go back to home directory
echo "  [✔] massdns installed."

echo "  [-] Installing puredns..."
go install github.com/d3mondev/puredns/v2@latest
echo "  [✔] puredns installed."

echo "  [-] Installing subfinder..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
echo "  [✔] subfinder installed."
echo

# --- Configuration File Setup ---
echo "[+] Setting up configuration files..."

echo "  [-] Configuring puredns resolvers..."
mkdir -p ~/.config/puredns
# Copy the resolver file from the script's directory
cp "$SCRIPT_DIR/resolvers.txt" ~/.config/puredns/resolvers.txt
echo "  [✔] puredns resolvers configured."

echo "  [-] Configuring Subfinder providers..."
mkdir -p ~/.config/subfinder
# Copy the provider config file from the script's directory
cp "$SCRIPT_DIR/provider-config.yaml" ~/.config/subfinder/
echo "  [✔] Subfinder providers configured."
echo

# --- Finalization ---
echo "================================================================="
echo "[*] SETUP COMPLETE! [*]"
echo "================================================================="
echo "[!] IMPORTANT: For all changes to take effect, you must reload your shell."
echo "[!] Run this command now: source ~/.bashrc"
echo
