# Cloudflare DNS Configuration

This deployment uses Cloudflare to manage DNS records for the custom domain used by the proxy.

## Architecture

```text
Domain Registrar
      ↓
Cloudflare DNS Nameservers
      ↓
A Record (e.g., api.yourdomain.me)
      ↓
AWS Elastic IP (IPv4)
```

## Configuration Steps

1. Add your domain to Cloudflare.
2. Change your domain registrar's nameservers to point to Cloudflare.
3. In the Cloudflare Dashboard, navigate to **DNS > Records**.
4. Create an **A Record**:
   - **Type**: A
   - **Name**: `api` (or whatever subdomain you prefer)
   - **IPv4 address**: `YOUR_AWS_ELASTIC_IP`
   - **Proxy status**: DNS Only (Gray Cloud)

## DNS Only vs. Proxied

> [!IMPORTANT]
> **Use DNS Only (Gray Cloud) for raw TCP VLESS traffic.**

### DNS Only (Gray Cloud)
Cloudflare acts purely as a DNS resolver. It returns your server's actual AWS Elastic IP to the client. The client then makes a direct TCP connection to your server. This is required for standard VLESS TCP setups.

### Proxied (Orange Cloud)
Cloudflare terminates the connection, caches content, and proxies traffic to your server. Cloudflare's standard proxying **only supports HTTP/HTTPS traffic**. It does not support arbitrary TCP traffic or raw VLESS without wrapping it in WebSockets (WSS) or gRPC. Enabling the Orange Cloud on a raw TCP VLESS port will break connectivity.

## DNS Diagnostics

To verify your DNS configuration is correct and has propagated, use `dig` or `nslookup`:

```bash
# Using dig
dig api.yourdomain.me +short

# Using nslookup
nslookup api.yourdomain.me
```

The output should show your AWS Elastic IP. If it shows Cloudflare IPs (e.g., `104.x.x.x`), the record is set to "Proxied" (Orange Cloud) and must be changed.
