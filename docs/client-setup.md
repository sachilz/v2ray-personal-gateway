# Client Setup Guide

This document explains how to configure various client applications to connect to your VLESS proxy.

## VLESS URI Format

Configuration is often shared via a VLESS URI. A generic URI looks like this:

```text
vless://YOUR_UUID@YOUR_DOMAIN:443?encryption=none&security=tls&type=tcp&sni=YOUR_DOMAIN#AWS-VLESS
```

**Parameters:**
* `vless://`: The protocol identifier.
* `YOUR_UUID`: The client's unique identifier (password).
* `YOUR_DOMAIN`: The server address (hostname).
* `443`: The port the server is listening on.
* `encryption=none`: Standard for VLESS when wrapped in TLS.
* `security=tls`: Indicates TLS is used for the transport layer.
* `type=tcp`: The underlying network transport protocol.
* `sni=YOUR_DOMAIN`: The Server Name Indication used for TLS validation.
* `#AWS-VLESS`: An optional URL-encoded remark/name for the connection.

> [!NOTE]
> Ensure URL parameters are properly encoded (e.g., spaces as `%20`).

---

## Windows: v2rayN

v2rayN is a popular Windows GUI for Xray/V2Ray.

1. **Installation**: Download the latest release from the official GitHub repository and extract it.
2. **Importing Profile**: 
   - Copy your VLESS URI to the clipboard.
   - Open v2rayN.
   - Click `Servers` -> `Import bulk URL from clipboard` (or use `Ctrl+V`).
3. **Selecting Profile**: Click on the imported server profile and press `Enter` to make it active (it should have a checkmark).
4. **System Proxy**: In the system tray icon, right-click and set `System Proxy` to `Set system proxy` to route Windows traffic through it.
5. **Global Routing**: For all traffic, set `Routing` to `Global`. For bypassing local IPs, use `Bypass LAN`.
6. **Testing**: Select the profile and press `Ctrl+P` to test true latency/ping.
7. **Logs**: If the connection fails, view the log pane at the bottom of the v2rayN window to identify TLS or dialing errors.

---

## iOS / macOS: V2Box

V2Box is an application for iOS and macOS.

1. **Import URI**: Copy the URI, open V2Box, and use the `+` button to import from the clipboard.
2. **Select Profile**: Tap the profile in the list to make it the active selection.
3. **Connect**: Tap the large toggle button on the home screen to connect. A VPN profile prompt may appear on the first use; allow it.
4. **Inspect Logs**: If it fails to connect, check the `Logs` tab. V2Box is often strict about TLS validation.
5. **Certificate Verification**: If you see TLS verification errors, ensure your SNI matches the domain of the valid Let's Encrypt certificate on the server.
   * *Diagnostic Workaround*: You can enable `allowInsecure=1` in the profile settings to bypass verification temporarily, but understand this compromises TLS security.

---

## Android: NetMod

NetMod is an alternative client for Android supporting VLESS.

1. **Import Profile**: Open the app, press the `+` icon, and select import from clipboard to paste the URI.
2. **Connecting**: Press the prominent connect button.
3. **Logs**: Use the log viewer in the app menu to debug connection issues.
4. **Testing DNS / External IP**: Once connected, open a browser and visit `https://api.ipify.org` to verify your IP has changed to the AWS server's IP.

---

## ALPN and Fingerprint Settings

You may see options for ALPN and Fingerprint in client configurations.

* **ALPN (Application-Layer Protocol Negotiation)**: E.g., `h2, http/1.1`. Used during TLS handshake to negotiate the application protocol.
* **Fingerprint (uTLS)**: E.g., `chrome`, `firefox`. Attempts to make the TLS handshake packet structure mimic a standard web browser to evade DPI (Deep Packet Inspection).

> [!NOTE]
> Fingerprinting is not a guaranteed method to bypass advanced network controls, but it can help blend traffic with normal HTTPS traffic.
