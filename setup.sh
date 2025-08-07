#!/bin/bash
set -e

echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing dependencies..."
sudo apt install -y git curl wget unzip make build-essential python3-pip

echo "[*] Installing Go..."
GO_VERSION="1.22.3"
cd /tmp
wget -q https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

echo "[*] Installing massdns..."
cd ~
git clone https://github.com/blechschmidt/massdns.git
cd massdns && make
sudo cp bin/massdns /usr/local/bin/

echo "[*] Installing puredns..."
go install github.com/d3mondev/puredns/v2@latest

echo "[*] Installing subfinder..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo "[*] Downloading resolver files..."
mkdir -p ~/.config/puredns
wget -q https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt -O ~/.config/puredns/resolvers.txt
wget -q https://raw.githubusercontent.com/trickest/resolvers/main/resolvers-trusted.txt -O ~/.config/puredns/resolvers-trusted.txt

echo "[*] Setting up Subfinder provider-config.yaml..."
mkdir -p ~/.config/subfinder
cp "provider-config.yaml" ~/.config/subfinder/
echo "[*] provider-config.yaml copied to ~/.config/subfinder"

echo "[*] Done. Running source ~/.bashrc or Reload your terminal or run: source ~/.bashrc"
source ~/.bashrc


