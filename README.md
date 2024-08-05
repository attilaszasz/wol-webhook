# wol-webhook
A lightweight web api app that can send a WakeOnLan magic package to a given MAC address

## Hosting in Docker:

#### Docker
```bash
docker run -d --network=host -t ghcr.io/attilaszasz/wol-webhook:latest
```

#### Docker Compose
```yaml
version: '3.9'
services:
  wol-webhook:
    image: ghcr.io/attilaszasz/wol-webhook:latest
    container_name: wol
    network_mode: host
    restart: unless-stopped
    environment:
      - ASPNETCORE_HTTP_PORTS=12563  # Optional
```