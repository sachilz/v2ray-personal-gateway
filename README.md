# V2Ray/Xray VLESS Server Deployment

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-AWS%20EC2%20%7C%20Ubuntu-orange.svg)

Personal V2Ray/Xray VLESS server deployment on AWS EC2 with 3X-UI, Cloudflare DNS, Let's Encrypt TLS, firewall hardening, diagnostics, and client configuration.

## Features
* **AWS EC2 Deployment**: Managed cloud infrastructure on Ubuntu Linux.
* **3X-UI Management**: Web-based administration for users and nodes.
* **Xray Core**: High-performance VLESS proxy implementation.
* **TCP/RAW Transport**: Direct TCP connections bypassing Cloudflare proxy limits.
* **TLS Security**: Let's Encrypt automated certificates.
* **Cloudflare DNS**: Reliable, fast DNS resolution (DNS-Only).
* **Security Hardening**: UFW and AWS Security Groups configured for least privilege.
* **Comprehensive Diagnostics**: Included scripts for health and network testing.
* **Client Support**: Verified configurations for Windows (v2rayN), macOS/iOS (V2Box), and Android (NetMod).

---

## Architecture

```mermaid
graph TD
    Client[Client Device\n(V2Box / v2rayN / NetMod)] -->|DNS Lookup| CF_DNS[Cloudflare DNS\n(DNS Only / Gray Cloud)]
    CF_DNS -.->|Returns AWS IP| Client
    Client -->|TCP/TLS\nPort 443| AWS_EC2[AWS EC2 Instance\nSingapore ap-southeast-1]
    
    subgraph AWS Cloud
        AWS_EC2 --> |Panel Access\nPort 44662| Panel[3X-UI Panel\n(Management Interface)]
        AWS_EC2 --> |Proxy Traffic\nPort 443 / 52585| Xray[Xray Core\n(VLESS/TLS Handler)]
    end
    
    Xray -->|Forwarded Traffic| Internet[Public Internet]
```

**Traffic Flow:**
1. Client resolves `proxy.example.com`.
2. DNS returns the AWS Elastic IP.
3. Client establishes a TCP connection to Port 443.
4. TLS handshake occurs, authenticated by the Let's Encrypt certificate.
5. Xray validates the VLESS authentication (UUID).
6. Permitted traffic is forwarded to the Internet.

*For more details, read [Architecture](docs/architecture.md).*

---

## Prerequisites

### AWS
* AWS account with EC2 access.
* Elastic IP allocated.
* Ubuntu 22.04 or 24.04 LTS instance (e.g., in `ap-southeast-1`).

### Domain
* Custom domain registered (e.g., Namecheap).
* Cloudflare DNS management configured.

### Client
* V2Box (iOS/macOS)
* v2rayN (Windows)
* NetMod (Android)

---

## Server Preparation

Connect to your EC2 instance via SSH and run system updates:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl wget unzip git jq ca-certificates
```

Check system resources:
```bash
hostnamectl
free -h
df -h
ip addr
```

---

## 3X-UI Installation

We use the official 3X-UI installation script. **Review the script in `scripts/install-3xui.sh` before running.**

```bash
sudo bash scripts/install-3xui.sh
```
*Note: This downloads and executes the script directly from the official MHSanaei GitHub repository.*

### 3X-UI Panel Security
* Default port: Often assigned during setup (e.g., `44662`).
* Do not expose this port to the entire internet. Use AWS Security Groups and UFW to restrict access to your `ADMIN_IP` only.
* Change default credentials immediately on first login.

---

## Configuration & Deployment

1. **DNS**: Point a Cloudflare A-Record (DNS Only) to your AWS Elastic IP. See [Cloudflare DNS Guide](docs/cloudflare-dns.md).
2. **TLS**: Use the panel to request an HTTP-01 Let's Encrypt certificate. See [TLS Certificates Guide](docs/tls-certificates.md).
3. **Firewall**: Configure AWS Security Groups and UFW. See [AWS Security Guide](docs/aws-security.md).
4. **VLESS Inbound**: Create a VLESS TCP inbound with TLS enabled. Refer to the sanitized `configs/vless-template.json` for structural reference.
5. **Client Setup**: Import the resulting URI into your client. See [Client Setup Guide](docs/client-setup.md).

---

## Security

Security is managed at multiple layers:
1. **Cloud Firewall (AWS SG)**: Blocks all traffic except specific ports.
2. **OS Firewall (UFW)**: Redundant local protection.
3. **SSH Restrictions**: Disable password login; use SSH keys; restrict source IP.
4. **Secret Management**: Never commit UUIDs, private keys, or API tokens to Git. This repository uses `.gitignore` to prevent secret leakage.

### Security Checklist
- [ ] SSH restricted via key and IP
- [ ] Strong 3X-UI credentials set
- [ ] Panel port restricted to Admin IP
- [ ] UFW enabled
- [ ] AWS SG hardened
- [ ] No secrets committed to Git

---

## Diagnostics and Monitoring

Execute the provided shell scripts for quick system diagnostics:

```bash
# Verify listening ports
sudo bash scripts/verify-ports.sh

# Monitor basic server health
bash scripts/system-health.sh

# Test external connectivity
bash scripts/network-test.sh
```

---

## Disaster Recovery

If the EC2 instance fails:
1. Create a new EC2 instance.
2. Re-assign the existing Elastic IP to the new instance (DNS remains unchanged).
3. Run system preparation and `scripts/install-3xui.sh`.
4. Restore configuration from secure offline backups (never from GitHub).
5. Re-issue TLS certificates.

---

## Cost Management (AWS)

Monitor your AWS costs carefully. Key drivers include:
* **EC2 Instance Hourly Rates**: Varies by instance size.
* **Elastic IP (IPv4) Charges**: AWS charges an hourly rate for all public IPv4 addresses.
* **Data Transfer Out (Egress)**: AWS charges high rates for data leaving the region. Proxy traffic generates significant egress.
* **EBS Storage**: Volume costs per GB/month.

Use **AWS Cost Explorer** and set up **AWS Budgets** alerts.

---

## Lessons Learned

### Lesson 1 — Client compatibility matters
Different clients can use different Xray cores, versions, and validation behavior. What works on NetMod may fail on V2Box due to stricter TLS validation.

### Lesson 2 — TLS hostname consistency matters
Ensure: `Domain` = `SNI` = `Certificate SAN`.

### Lesson 3 — `flow=none` is not universally accepted
Do not include unnecessary `flow` parameters. If a client rejects `flow=none`, remove the parameter entirely.

### Lesson 4 — DNS-only vs proxied Cloudflare
DNS-only is not the same thing as Cloudflare proxying. Orange Cloud breaks raw TCP VLESS.

### Lesson 5 — AWS instance/network characteristics matter
Cloud provider performance is affected by instance type, network model, region, and traffic path. AWS burstable instances (`t2`/`t3`) have network limits that throttle after credits are exhausted.

### Lesson 6 — Ping is not bandwidth
Low latency does not guarantee high throughput. 

---

## Command Reference

### Server & Resource Monitoring
```bash
uname -a               # OS details
free -h                # RAM usage
df -h                  # Disk usage
uptime                 # Server uptime
ip addr                # Network interfaces
ss -tulpn              # Listening ports
```

### Firewall & Diagnostics
```bash
sudo ufw status verbose
dig YOUR_DOMAIN
openssl s_client -connect YOUR_DOMAIN:443 -servername YOUR_DOMAIN
```

### Services & Logs
```bash
systemctl status x-ui
journalctl -u x-ui -n 100 --no-pager
```

*(Note: The exact service name may vary, e.g., `x-ui` or `3x-ui`)*

---

## Repository Structure

```text
v2ray-server-deployment/
├── README.md                      # Main project documentation
├── LICENSE                        # MIT License
├── .gitignore                     # Prevents secret leakage
├── configs/
│   ├── vless-template.json        # Sanitized VLESS server template
│   └── client-template.json       # Sanitized client profile template
├── scripts/
│   ├── install-3xui.sh            # Safe 3X-UI installation wrapper
│   ├── verify-ports.sh            # Firewall and port diagnostics
│   ├── system-health.sh           # CPU/RAM/Disk monitoring
│   └── network-test.sh            # Basic connectivity tests
├── docs/
│   ├── architecture.md            # Topology and traffic flow
│   ├── aws-security.md            # EC2 SG and UFW hardening
│   ├── cloudflare-dns.md          # DNS configuration details
│   ├── tls-certificates.md        # Let's Encrypt and SNI
│   ├── client-setup.md            # v2rayN, V2Box, NetMod guides
│   ├── troubleshooting.md         # Matrix for common errors
│   └── performance-testing.md     # AWS limits and speed tests
└── .github/
    └── workflows/
        └── validate-config.yml    # CI/CD for JSON/Shell syntax
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.