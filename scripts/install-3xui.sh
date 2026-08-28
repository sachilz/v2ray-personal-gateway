#!/usr/bin/env bash
set -Eeuo pipefail

# ==============================================================================
# Script: install-3xui.sh
# Purpose: Safely update system dependencies and install the official 3X-UI panel.
# ==============================================================================

# Ensure script is run as root
if [[ "${EUID}" -ne 0 ]]; then
  echo "❌ Error: This script must be run as root or with sudo."
  exit 1
fi

echo "✅ Running with root privileges."

# Verify running on a supported OS (Ubuntu/Debian)
if [ ! -f /etc/os-release ]; then
    echo "❌ Error: Unsupported OS. This script requires Ubuntu or Debian."
    exit 1
fi

source /etc/os-release
if [[ "${ID}" != "ubuntu" && "${ID}" != "debian" ]]; then
    echo "❌ Error: Unsupported OS: ${ID}. This script requires Ubuntu or Debian."
    exit 1
fi

echo "✅ OS Verification passed: ${PRETTY_NAME}"

# Update packages and install dependencies
echo "🔄 Updating package lists..."
apt-get update -y

echo "📦 Installing required dependencies (curl, wget, unzip, git, jq, ca-certificates)..."
apt-get install -y curl wget unzip git jq ca-certificates

echo "✅ System dependencies installed successfully."

# Note: We use the official installation script from the 3X-UI repository.
# Before running remote scripts in a production environment, always verify the source.
# Official repo: https://github.com/MHSanaei/3x-ui
echo "⬇️ Downloading and executing the official 3X-UI installation script..."

# We execute the script directly. This is standard for 3X-UI, but note the security implication.
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

echo "✅ 3X-UI installation process completed."
echo "ℹ️ Note: If this is a fresh install, 3X-UI should be available on the port you specified during setup."
echo "⚠️ IMPORTANT: Do not expose the panel port to the entire internet. Secure it with a firewall!"
