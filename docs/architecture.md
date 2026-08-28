# System Architecture

This document describes the high-level architecture of the V2Ray/Xray VLESS deployment.

## Overview

The infrastructure relies on a standard proxy topology where traffic from client devices is tunneled through an AWS EC2 instance via the VLESS protocol using Xray Core, managed by the 3X-UI panel.

## Topology Diagram

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

## Component Roles

### 1. 3X-UI Panel vs Xray Core
It is critical to distinguish between the management interface and the actual proxy engine:
* **3X-UI Panel**: This is a web-based dashboard used to configure users, inbound connections, and view traffic statistics. It typically runs on a restricted port (e.g., `44662`) and should ideally only be accessible from trusted administrative IPs.
* **Xray Core**: This is the underlying network proxy software. It handles the actual incoming VLESS connections, TLS decryption, and forwards traffic to the internet. It listens on public ports like `443` or `52585`.

### 2. DNS (Cloudflare)
Cloudflare is used purely as a DNS provider (DNS Only / Gray Cloud). Because standard Cloudflare HTTP proxying does not support raw TCP/VLESS traffic without WebSockets or specialized configurations, we use DNS to simply resolve the custom domain to the AWS Elastic IP.

### 3. Traffic Flow

1. **DNS Resolution**: The client resolves `proxy.yourdomain.me`. Cloudflare returns the AWS Elastic IP.
2. **TCP Connection**: The client establishes a raw TCP connection to the AWS server.
3. **TLS Handshake**: A TLS handshake occurs. Xray validates the connection using the Let's Encrypt certificate. The client verifies the server certificate matches the SNI (Server Name Indication).
4. **VLESS Authentication**: Xray authenticates the connection using the configured UUID.
5. **Traffic Forwarding**: Xray forwards the permitted traffic out to the internet.
6. **Return Path**: The response from the internet returns through the Xray core and back over the same secure tunnel to the client.

## OSI Layer Breakdown
* **DNS**: Resolves domain to IP.
* **TCP**: Provides reliable connection layer.
* **TLS**: Encrypts the transport and provides server authentication.
* **VLESS**: Lightweight proxy protocol for user authentication and routing.
* **Xray**: Software implementation handling VLESS and routing.
* **Internet**: Final destination of traffic.
