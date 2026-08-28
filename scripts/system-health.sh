#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: system-health.sh
# Purpose: Monitor basic server health and resource usage.
# ==============================================================================

echo "🏥 System Health Report"
echo "========================================"

echo "⏱️ UPTIME AND LOAD AVERAGE:"
uptime
echo ""

echo "🧠 MEMORY USAGE:"
free -h
echo ""

echo "💾 DISK USAGE:"
df -h /
echo ""

echo "🌐 NETWORK INTERFACES:"
ip -br addr
echo ""

echo "🔧 SERVICE STATUS:"
# Depending on the installation method, the service might be x-ui or 3x-ui
if systemctl is-active --quiet x-ui; then
    echo "✅ x-ui service is running."
else
    echo "❌ x-ui service is NOT running (or not installed under this name)."
fi

echo "========================================"
echo "✅ Health check completed."
