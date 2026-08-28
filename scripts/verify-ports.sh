#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: verify-ports.sh
# Purpose: Diagnose and verify listening ports and firewall rules.
# ==============================================================================

echo "🔍 Verifying active listening ports..."
echo "----------------------------------------"

# Check ports using ss
LISTENING=$(ss -tulpn)

check_port() {
  local port=$1
  local service_name=$2
  
  if echo "$LISTENING" | grep -q ":$port\b"; then
    echo "✅ [OK] Port $port ($service_name) is listening."
  else
    echo "❌ [FAIL] Port $port ($service_name) is NOT listening."
  fi
}

check_port 22 "SSH"
check_port 80 "HTTP (ACME)"
check_port 443 "HTTPS/TLS Proxy"
check_port 52585 "Optional VLESS"
check_port 44662 "3X-UI Panel"

echo ""
echo "🛡️ Checking UFW Firewall Status..."
echo "----------------------------------------"
if command -v ufw >/dev/null 2>&1; then
  # Requires sudo/root to check ufw status
  if [[ "${EUID}" -ne 0 ]]; then
    echo "⚠️ Cannot check UFW status without root privileges. Try running with sudo."
  else
    ufw status verbose
  fi
else
  echo "ℹ️ UFW is not installed."
fi

echo ""
echo "ℹ️ Note: This script is for diagnostics only and does not modify any rules."
