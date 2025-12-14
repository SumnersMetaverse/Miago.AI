# MIAGO Platform Network Configuration

## Overview
This document explains the network architecture and port mappings for the MIAGO (Multi-Integrated Autonomous Graphing Operations) platform.

## Version
Current Version: `1.0.1.0.11.1.0.1`

## Network Configuration

### Base IP
- **IP**: `192.0.0.0/24`
- **Network**: Docker bridge network for service isolation

### Port Mappings

| Port  | Service            | Description                          | Type      |
|-------|-------------------|--------------------------------------|-----------|
| 73571 | OAuth Entry       | `_0AUTH_ENTRY` - Authentication      | Internal  |
| 6379  | Redis             | Data persistence/cache layer         | Internal  |
| 8080  | HTTP Server       | Primary HTTP service                 | Internal  |
| 3003  | Docusaurus        | Documentation server (external)      | External  |

### Localhost Instances

The platform supports multiple localhost configurations:

1. **Primary Instance**: `localhost8000.3679.8080`
   - Ports: 8000, 3679, 8080
   - Purpose: Twittisphere primary instance

2. **OAuth Instance**: `localhost_oauth`
   - Port: 73571
   - Purpose: 3AF_0AUTH authentication service

3. **Redis Instance**: `localhost_redis`
   - Port: 6379
   - Purpose: Data persistence layer

## Service Dependencies

```
┌─────────────────┐
│  Docusaurus     │ (Port 3003 - Standalone)
└─────────────────┘

┌─────────────────┐
│  HTTP Service   │ (Port 8080)
└────────┬────────┘
         │
         ├──────> OAuth Service (Port 73571)
         │              │
         └──────────────┴──────> Redis (Port 6379)
```

## Configuration Files

1. **miago-config.yml**: Main platform configuration
2. **docker-compose.yml**: Service orchestration
3. **.env.example**: Environment variable template

## Legacy Keys

⚠️ **IMPORTANT**: The following keys must NOT be updated until fully verified and accounts are accredited:

- `SEGMENT_ANALYTICS_KEY`
- `LD_CLIENT_ID`

## Quick Start

### Using Docker Compose

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration
nano .env

# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Individual Service Access

- **Documentation**: http://localhost:3003
- **HTTP Server**: http://localhost:8080
- **OAuth Service**: http://localhost:73571
- **Redis**: redis://localhost:6379

## Platform Architecture

- **Web Layers**: 9 total (3 existing + 6 new)
- **Domain**: miago.ai
- **User Format**: @username.miago.ai
- **Authentication**: 3AF_0AUTH (Multi, Integrated, Autonomous, Graphing, Operations)

## Security Notes

1. All services run in isolated Docker network (192.0.0.0/24)
2. Only Docusaurus is exposed externally (0.0.0.0:3003)
3. Internal services communicate via Docker network
4. Legacy keys are protected and require verification before updates
5. Environment variables should be configured in `.env` (not committed to git)

## Troubleshooting

### Port Conflicts
If ports are already in use:
```bash
# Check what's using a port
lsof -i :73571
lsof -i :6379
lsof -i :8080
lsof -i :3003

# Modify ports in docker-compose.yml if needed
```

### Service Dependencies
Ensure services start in correct order:
1. Redis (standalone)
2. OAuth Service (depends on Redis)
3. HTTP Service (depends on OAuth + Redis)
4. Docusaurus (standalone)

### Network Isolation
Services communicate via Docker network names:
- Use `redis` not `localhost:6379` from within containers
- Use `oauth-service` not `localhost:73571` from within containers

## External Secrets Integration

The platform uses external-secrets as base image:
```
ghcr.io/external-secrets/external-secrets:sha256-a4e1d50ba3f42fcbd818df963086ab81049c7fef6b81c34dd5360c5f253f916a.att
```

This provides secure secrets management for the MIAGO platform.
