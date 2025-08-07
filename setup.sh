#!/bin/bash
# A robust script to set up a VPS with essential recon tools.
# This script is designed to be run from anywhere, as it automatically
# detects its own location to find necessary configuration files.
# It also auto-detects system architecture for Nuclei installation.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Automatically find the script's own directory ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "================================================================="
echo "            VPS Recon Tools Auto-Installer by skshadan"
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
    echo "  [!] massdns directory already exists. Skipping clone."
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

# --- NEW: httpx Installation ---
echo "  [-] Installing httpx..."
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
echo "  [✔] httpx installed."

# --- NEW: Nuclei Installation (with auto-detection) ---
echo "  [-] Installing Nuclei..."
NUCLEI_VERSION="3.4.7" # You can update this version as needed
# Detect OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    *)
        echo "  [!] Unsupported architecture: $ARCH. Please install Nuclei manually."
        exit 1
        ;;
esac
# Download and install
NUCLEI_URL="https://github.com/projectdiscovery/nuclei/releases/download/v${NUCLEI_VERSION}/nuclei_${NUCLEI_VERSION}_${OS}_${ARCH}.zip"
echo "  [*] Downloading Nuclei from: $NUCLEI_URL"
cd /tmp
wget -q "$NUCLEI_URL"
unzip -o "nuclei_${NUCLEI_VERSION}_${OS}_${ARCH}.zip" # -o overwrites without asking
sudo mv nuclei /usr/local/bin/
rm "nuclei_${NUCLEI_VERSION}_${OS}_${ARCH}.zip"
echo "  [✔] Nuclei installed."
echo

# --- Configuration File Setup ---
echo "[+] Setting up configuration files..."

echo "  [-] Configuring puredns resolvers..."
mkdir -p ~/.config/puredns
cp "$SCRIPT_DIR/resolvers.txt" ~/.config/puredns/resolvers.txt
echo "  [✔] puredns resolvers configured."

echo "  [-] Configuring Subfinder providers..."
mkdir -p ~/.config/subfinder
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
