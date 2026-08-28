# TLS Certificates and SNI

Securing the proxy connection with TLS is crucial. We use Let's Encrypt to obtain free, automated certificates.

## TLS Basics

* **Certificate (`fullchain.pem`)**: Publicly presented by the server to prove its identity.
* **Private Key (`privkey.pem`)**: Must be kept secret on the server. Used to decrypt TLS traffic and prove ownership of the certificate.

> [!CAUTION]
> **NEVER COMMIT `privkey.pem` TO GIT OR SHARE IT.** If your private key is exposed, your TLS encryption is compromised.

## Obtaining a Certificate

We recommend using `acme.sh` or `certbot` to obtain the certificate. The 3X-UI panel often has built-in ACME request capabilities using the HTTP-01 challenge.

For the HTTP-01 challenge to succeed:
1. Port `80` must be open in the AWS Security Group and UFW.
2. DNS must correctly point to the server's IP.

Example paths for certificates used in Xray configurations:
* Certificate: `/root/cert/YOUR_DOMAIN/fullchain.pem`
* Private Key: `/root/cert/YOUR_DOMAIN/privkey.pem`

## SNI (Server Name Indication)

SNI is an extension to the TLS protocol that allows a client to indicate which hostname it is attempting to connect to at the start of the handshaking process.

**Important Distinctions:**
* `SNI` = `example.com` (A hostname)
* `HTTP URL` = `https://example.com/path` (Not an SNI)
* `Host Header` = Used in HTTP, technically separate from the TLS SNI.

> [!NOTE]
> SNI spoofing (setting the SNI to a popular website like `zoom.us`) does not magically route your traffic through that website's servers unless your server IP is actually behind that service's infrastructure.

## Certificate Validation

When a client connects:
```text
Client sends SNI -> Server responds with Certificate -> Client verifies Certificate matches SNI
```

If the client sets `SNI = domain-A.com` but the server returns a certificate for `domain-B.com`, a strict client will reject the connection to prevent Man-in-the-Middle (MITM) attacks.

### Workarounds (`allowInsecure`)
Some clients have an option like `allowInsecure=1` (or "Allow Insecure" toggle in UI). This disables certificate hostname verification.

> [!WARNING]
> Disabling certificate verification (`allowInsecure=1`) reduces TLS security and makes the connection vulnerable to MITM attacks. It should only be used as a diagnostic tool or temporary compatibility workaround, not a permanent production solution.

**Preferred Fix**: Ensure the `Domain` used by the client equals the `SNI`, which equals the `Certificate SAN` (Subject Alternative Name).

## TLS Diagnostics

Use OpenSSL to manually verify the server's certificate from your local machine:

```bash
# Check the certificate presented for a specific SNI
openssl s_client -connect YOUR_SERVER_IP:443 -servername YOUR_DOMAIN
```

Look for the `subject=` and `issuer=` fields to verify the correct Let's Encrypt certificate is being returned.
