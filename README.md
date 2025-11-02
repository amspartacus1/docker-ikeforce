# **WIP**: IKEForce on python:2.7.17-alpine

> **Note**: Use only on systems you own or have explicit written permission to test.

This section provides ready-to-use instructions to build and run a Docker image that bundles **IKEForce** with its Python 2.7 dependencies (including the legacy `pyip` package that supplies the `udp` module).

---

## Files

- `Dockerfile` — Base image `python:2.7.17-alpine`, installs runtime deps (`bash`, `ca-certificates`, `libpcap`) and Python packages: `pyip==0.7`, `scapy==2.4.5`, `pycrypto==2.6.1`, `cryptography==2.9.2`, `pyOpenSSL==16.2.0`, `pexpect==4.8.0`. Clones IKEForce.

> The `cryptography==2.9.2` pin is the last version supporting Python 2.7. `pyip` provides the `udp` module that IKEForce imports.

---

## Quick start

### Build
```bash
# Standard image
docker build -t ikeforce:py27 .
```

### Run
```bash
# Show help
docker run --rm -it --net=host --cap-add=NET_RAW --cap-add=NET_ADMIN ikeforce:py27 -h

# Example usage (replace with your target args)
docker run --rm -it --net=host --cap-add=NET_RAW --cap-add=NET_ADMIN   ikeforce:py27 --host 192.0.2.10 --trans 1 --mode aggressive
```

**Why `--net=host` and capabilities?** IKE/IKEv2 probing uses Scapy/raw sockets. Granting `NET_RAW` and `NET_ADMIN` allows packet crafting; host networking avoids NAT interference. If your setup requires stricter isolation, you may try without `--net=host`, but ensure the container can reach the target and has raw‑socket permissions.

---

## Optional: pin to a specific IKEForce commit (reproducible builds)

If you want an exact revision of IKEForce, add this to the Dockerfile after cloning:

```dockerfile
# Add near the git clone step
ARG IKEFORCE_REF=master
RUN cd /opt/ikeforce && git fetch --depth 1 origin ${IKEFORCE_REF} && git checkout -qf ${IKEFORCE_REF}
```

Build with a tag or commit:
```bash
docker build --build-arg IKEFORCE_REF=a1b2c3d -t ikeforce:py27 .
```

## Troubleshooting

- **"Missing 'udp' library"** — This image installs `pyip==0.7`, which provides `udp`. If you still see the message, confirm your image is rebuilt and you’re running the updated tag.
- **`CryptographyDeprecationWarning` on Python 2** — Harmless.
- **No packets observed / empty results** — Ensure `--cap-add=NET_RAW --cap-add=NET_ADMIN` are present and your user has permission to enable host networking. Some desktop environments (Docker Desktop on macOS/Windows) handle `--net=host` differently; consider running on Linux or adjusting firewall rules.
- **Interface selection** — If probing a specific interface, pass arguments supported by IKEForce/Scapy or run with host networking and route appropriately.
