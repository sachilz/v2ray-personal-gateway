# Troubleshooting Guide

This guide helps diagnose and resolve common issues with the V2Ray/Xray server deployment.

## Troubleshooting Matrix

| Problem | Possible Cause | Diagnostic | Fix |
|---|---|---|---|
| Cannot SSH | SG/UFW block, bad key | Run `ssh -v user@ip` | Fix AWS Security Group or UFW rule. |
| Port closed | SG/UFW block, service dead | Run `ss -tulpn`, `ufw status` | Correct firewall rule; restart Xray. |
| TLS fails | Cert/SNI mismatch | `openssl s_client` | Ensure domain matches SNI and Cert SAN. |
| V2Box fails | Client/core strict config | Check client logs | Correct configuration; verify TLS. |
| `flow` error | Unsupported flow value | Check client logs | Remove the `flow` parameter from config. |
| DNS fails | DNS record incorrect | `dig YOUR_DOMAIN` | Correct Cloudflare DNS A record. |
| Slow speed | Network/instance limits | Throughput test | Check AWS burst credits or instance size. |
| Slow speed (AWS) | Outdated core + Cubic TCP | Direct HTTP download | Update Xray-core in panel & enable BBR. |
| Panel inaccessible | Firewall blocking panel port | `ss`, `ufw` | Open panel port (44662) for Admin IP. |

---

## Common Issues in Detail

### 1. `flow doesn't support none` Error
**Cause**: Some client versions or specific Xray core combinations reject `flow=none` when it is explicitly defined in the configuration, interpreting it as an invalid value instead of an empty configuration.
**Fix**: Remove the `flow` parameter entirely if XTLS/Vision flow control is not required.
* **BAD**: `flow=none`
* **GOOD**: *(no flow parameter present)*

### 2. TLS SNI Mismatch (NetMod works, V2Box fails)
**Cause**: Different clients have different TLS validation behaviors. NetMod might default to a less strict validation or ignore minor mismatches, while V2Box enforces strict SNI and certificate hostname matching.
**Fix**: Ensure your `Domain` used by the client equals the `SNI`, which equals the `Certificate hostname`.
* *Diagnostic workaround*: Use `allowInsecure=1` in V2Box only to test if the certificate is the issue. Do not leave this enabled for production.

### 3. DNS Resolution Issues
To verify DNS, run:
```bash
dig api.yourdomain.me
```
If this returns a Cloudflare IP (e.g., `104.21.x.x`) instead of your AWS Elastic IP, you have accidentally enabled Cloudflare Proxied mode (Orange Cloud). Change it to **DNS Only (Gray Cloud)**.

### 4. TLS Diagnostics
To check if the server is serving the correct Let's Encrypt certificate for your SNI, run this from your local machine:
```bash
openssl s_client -connect YOUR_DOMAIN:443 -servername YOUR_DOMAIN
```
Examine the output for:
* `subject=CN = YOUR_DOMAIN`
* `issuer=CN = R3, O = Let's Encrypt`
* Check the certificate chain and expiration date.

### 5. AWS EC2 t2.micro Speed Capped at ~10 Mbps
**Cause**: The server is using an outdated Xray-core build paired with Linux's default TCP congestion control (Cubic). Cubic backs off bandwidth conservatively on paths with variable latency (common for ISP-to-AWS routing), and the older core adds processing overhead. This combination throttles throughput even if CPU credits and network baseline caps are fine.
**Fix**:
1. Open the 3X-UI management script (`x-ui`).
2. Update Xray-core to the latest stable release (e.g., Option 2).
3. Enable Google's BBR TCP congestion control (e.g., Option 26).
4. Restart Xray and Reboot the VM.
5. Reconnect and retest; speeds should stabilize at a much higher throughput (e.g., 80-100 Mbps).
