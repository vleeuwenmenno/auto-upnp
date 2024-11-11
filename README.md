# Auto UPNP

A simple Docker container for automatic UPnP port forwarding. This container automatically forwards ports on your router with the use of upnpc.

## Features

- JSON-based port configuration
- Automatic port mapping renewal
- Configurable mapping duration
- Built on Alpine Linux for minimal footprint

## Usage

### Quick Start

```yaml
services:
  upnp:
    image: ghcr.io/vleeuwenmenno/auto-upnp:latest
    network_mode: host
    environment:
      - PORTS=[{"port": 80, "protocol": "tcp"}, {"port": 443, "protocol": "tcp"}]
```

### Environment Variables

- `PORTS`: JSON array of port mappings (required)
  - Format: `[{"port": number, "protocol": "tcp|udp"}, ...]`
- `UPNP_DURATION`: Renewal interval for port mappings (default: `86400` seconds/24 hours)

### Example Configurations

#### Game Server (Satisfactory)

```yaml
environment:
  PORTS:  |
  [
    {"port": 7777, "protocol": "udp"},
    {"port": 15000, "protocol": "udp"},
    {"port": 15777, "protocol": "udp"}
  ]
```

#### Web Server

```yaml
environment:
  PORTS:  |
  [
    {"port": 80, "protocol": "tcp"},
    {"port": 443, "protocol": "tcp"}
  ]
```

## Building

```bash
docker build -t auto-upnp .
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
