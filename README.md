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

## Usage:

Send a GET request to the app with the MAC address of the target computer:
```bash
wget http://{address}:12563/wol/00-11-22-33-44-55
```

> The MAC address should be in the format of `00-11-22-33-44-55`