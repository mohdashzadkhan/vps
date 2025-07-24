# VPS Auto Setup Script

This repository contains a one-shot installation script for setting up a fresh VPS with essential bug bounty and recon tools.

### ✅ Tools Installed

- [Go](https://go.dev/)
- [massdns](https://github.com/blechschmidt/massdns)
- [puredns](https://github.com/d3mondev/puredns)
- [subfinder](https://github.com/projectdiscovery/subfinder)
- Required system packages (git, curl, wget, make, build-essential, etc.)
- Resolver lists from [trickest/resolvers](https://github.com/trickest/resolvers)

---

### ⚙️ How to Use

```bash
git clone https://github.com/mohdashzadkhan/vps.git
cd vps
chmod +x setup.sh
./setup.sh
