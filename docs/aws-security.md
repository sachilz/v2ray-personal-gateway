# AWS Security and Firewall Configuration

This document covers the security hardening for the AWS EC2 instance, focusing on AWS Security Groups and the local UFW firewall.

## Architecture

Traffic must pass through two layers of network security before reaching the application:

```text
Internet
   ↓
AWS Security Group (Cloud Firewall)
   ↓
UFW (OS Firewall)
   ↓
Application (Xray / 3X-UI / SSH)
```

## 1. AWS Security Group

The Security Group acts as a virtual firewall for your EC2 instance to control incoming and outgoing traffic.

| Port  | Protocol | Source      | Purpose             |
| ----- | -------- | ----------- | ------------------- |
| 22    | TCP      | ADMIN_IP/32 | SSH Management      |
| 80    | TCP      | 0.0.0.0/0   | ACME/HTTP-01 Certs  |
| 443   | TCP      | 0.0.0.0/0   | TLS Proxy Traffic   |
| 52585 | TCP      | 0.0.0.0/0   | Optional VLESS port |
| 44662 | TCP      | ADMIN_IP/32 | 3X-UI Panel Access  |

> [!WARNING]
> Replace `ADMIN_IP` with your actual static or dynamic public IP address. Never open SSH (Port 22) or the 3X-UI Panel (Port 44662) to `0.0.0.0/0` unless strictly necessary, as they will be targeted by automated scanners.

## 2. UFW (Uncomplicated Firewall)

UFW provides a second layer of defense. If the AWS Security Group is misconfigured, UFW will still drop unauthorized packets at the OS level.

### Configuration Commands

```bash
# Deny all incoming by default, allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH from your specific IP only
sudo ufw allow from ADMIN_IP to any port 22 proto tcp

# Allow 3X-UI panel from your specific IP only
sudo ufw allow from ADMIN_IP to any port 44662 proto tcp

# Allow HTTP for Let's Encrypt renewal (ACME HTTP-01 challenge)
sudo ufw allow 80/tcp

# Allow public proxy traffic
sudo ufw allow 443/tcp
sudo ufw allow 52585/tcp

# Enable the firewall
sudo ufw enable

# Verify status
sudo ufw status verbose
```

## Security Best Practices

1. **SSH Keys**: Disable password authentication for SSH. Use Ed25519 or RSA keys.
2. **Least Privilege**: Only expose ports that are absolutely necessary.
3. **Panel Credentials**: Change the default 3X-UI credentials immediately upon installation.
4. **Regular Updates**: Keep the OS and the proxy software up to date.
5. **Fail2Ban**: Consider installing `fail2ban` to protect SSH if you must leave it open to `0.0.0.0/0`.
