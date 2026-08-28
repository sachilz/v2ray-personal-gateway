# Performance Testing and Provider Comparison

Understanding network performance is critical when deploying a proxy server. This document explains how to test performance correctly and how AWS burstable instances affect throughput.

## Performance Metrics

* **Latency (Ping/RTT)**: The time it takes for a packet to travel from the client to the server and back. Measured in milliseconds (ms).
* **Throughput (Bandwidth)**: The actual amount of data transferred over time. Measured in Mbps (Megabits per second).
* **Packet Loss**: Packets that fail to reach their destination, causing retransmissions and severe performance degradation.

> [!IMPORTANT]
> **Ping ≠ Download Speed.**
> Having a low latency (e.g., 20ms) does not guarantee high throughput. Throughput can be constrained by bandwidth limits, CPU contention, or TCP congestion windows.

## AWS T2/T3 Burstable Network Performance

When using AWS EC2 `t2`, `t3`, or `t4g` instances (common for personal deployments), network bandwidth is **burstable**.

**How it works:**
* Instances have a baseline bandwidth limit (e.g., 5 Gbps, though practically much lower for micro/nano instances).
* When transferring large amounts of data, the instance uses "network I/O credits".
* Once credits are exhausted, the bandwidth is severely throttled to a low baseline limit.
* Network performance depends heavily on the instance family, instance size, AWS generation, region, and network path.

**Conclusion:** Do not assume a fixed bandwidth value (like "AWS gives 1 Gbps") for a `t2.micro`. Performance will fluctuate based on the burst bucket.

> [!TIP]
> **TCP Congestion Control**: If you are experiencing speeds capped around ~10 Mbps on an AWS instance despite having CPU credits and network headroom, your issue is likely an outdated Xray-core build paired with Linux's default `Cubic` TCP congestion control. You should update Xray-core via the 3X-UI panel and enable Google's `BBR` congestion control (Options 2 and 26 in the `x-ui` menu).

## Safe Performance Testing

Do not rely on a single speed test. Test throughput to reputable endpoints:

1. **Speedtest.net CLI**: Tests raw bandwidth from the server to local ISPs.
2. **iPerf3**: The industry standard for network throughput testing. Requires an iPerf3 server endpoint.

```bash
# Example basic download test (diagnostics only, not definitive)
wget -O /dev/null http://speedtest.tele2.net/100MB.zip
```

## Cloud Provider Comparison Framework

When choosing a cloud provider for a proxy, evaluate these factors:

| Factor | AWS (EC2) | Akamai (Linode) / DigitalOcean | Google Cloud (GCP) |
|---|---|---|---|
| **Network Model** | Burstable limits on small instances, expensive outbound data. | Flat outbound data pool (e.g., 1TB/mo), high sustained throughput. | Premium/Standard tiers, very expensive egress pricing. |
| **Pricing** | High data transfer costs. Free tier available for small instances. | Predictable flat monthly rate including data. | Complex pricing, generally highest data transfer costs. |
| **IPv4 Cost** | AWS now charges ~$3.60/month per public IPv4 address. | Often included in base price, or smaller add-on fee. | Charges for public IPv4. |
| **Routing** | Excellent global backbone, region-dependent peering. | Good peering, often preferred for proxy servers due to cost. | Excellent premium backbone, costly. |

*Note: Verify current pricing and limits on the provider's official pricing pages before deployment.*
