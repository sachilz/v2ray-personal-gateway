#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: network-test.sh
# Purpose: Diagnose network connectivity and perform basic tests.
# ==============================================================================

echo "🌐 Network Connectivity Diagnostics"
echo "========================================"

echo "1️⃣ Testing external IP address..."
EXTERNAL_IP=$(curl -s --max-time 5 https://api.ipify.org || echo "Failed to fetch")
echo "External IP: $EXTERNAL_IP"
echo ""

echo "2️⃣ Testing basic latency (Ping to Cloudflare DNS 1.1.1.1)..."
ping -c 4 1.1.1.1 || echo "Ping failed."
echo ""

echo "3️⃣ Testing DNS Resolution (Example: github.com)..."
if command -v dig >/dev/null 2>&1; then
    dig +short github.com
elif command -v nslookup >/dev/null 2>&1; then
    nslookup github.com | grep -A 2 "Name:"
else
    echo "⚠️ 'dig' or 'nslookup' is not installed."
fi
echo ""

echo "4️⃣ Checking local routing table..."
ip route
echo ""

echo "========================================"
echo "ℹ️ These tests verify basic network connectivity from the server outward."
echo "They do not verify inbound proxy throughput. Latency (ping) does not equate to bandwidth."
