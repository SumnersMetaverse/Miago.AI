# MIAGO Platform Testing & Analysis Scripts

This directory contains scripts for testing and analyzing the MIAGO platform's network configuration, service connectivity, and contract roles.

## Scripts

### 1. test-network.sh

**Purpose**: Tests all service connections, verifies network configuration, and reports on credentials and platform origins.

**Features**:
- Tests connectivity to all services (OAuth, Redis, HTTP, Docusaurus)
- Verifies port accessibility
- Reports on credentials and their origins
- Shows Docker configuration and images
- Provides service dependency mapping
- Lists verification checklist
- Gives recommendations for startup and management

**Usage**:
```bash
./test-network.sh
```

**Output**:
- Console output with colored status indicators
- Service connectivity test results
- Credentials and platform mapping
- Docker images and origins
- Service dependency diagrams
- Recommendations for deployment

### 2. compile-contracts.sh

**Purpose**: Compiles and analyzes contract roles, identifies signers, payers, payees, and contract creators.

**Features**:
- Identifies contract creators for each service
- Classifies contract signers
- Distinguishes between payers (Accounts Payable) and payees (Accounts Receivable)
- Maps payment flows between services
- Analyzes legacy credential contracts
- Generates comprehensive reports

**Usage**:
```bash
./compile-contracts.sh
```

**Output Files**:
- `contract-compilation-report.txt` - Human-readable full report
- `contract-compilation-report.json` - Machine-readable data
- `contract-roles-quick-ref.txt` - Quick reference card

**Report Sections**:
1. Contract Role Compilation
2. Legacy Credential Contracts
3. Contract Hierarchy & Payment Flows
4. Summary by Role
5. Verification Requirements

## Service Roles Summary

### Contract Creators
1. **External Secrets** (Master) - Security contracts
2. **OAuth Service** (Port 73571) - Authentication contracts
3. **HTTP Server** (Port 8080) - Service level agreements
4. **Redis** (Port 6379) - Data storage contracts
5. **Docusaurus** (Port 3003) - Documentation licenses

### Contract Signers
- All services above plus:
- Segment Analytics (Legacy)
- LaunchDarkly (Legacy)

### Accounts Payable (Payers)
- **HTTP Server** → OAuth + Redis
- **Redis** → Infrastructure providers
- **Docusaurus** → Hosting/CDN
- **Platform** → Segment Analytics & LaunchDarkly

### Accounts Receivable (Payees)
- **External Secrets** ← All services
- **OAuth Service** ← HTTP Server
- **HTTP Server** ← End users

## Payment Flow

```
Users → HTTP Server → (OAuth + Redis)
All Services → External Secrets
Services → External Infrastructure
```

## Prerequisites

### For test-network.sh:
- Bash shell
- `nc` (netcat) or bash TCP support
- Docker (optional, for image inspection)
- `.env` file configured (or uses `.env.example`)

### For compile-contracts.sh:
- Bash shell
- `.env` file (optional)
- Write permissions for report generation

## Environment Variables

Both scripts read from `.env` or fall back to `.env.example`:

```bash
MIAGO_VERSION=1.0.1.0.11.1.0.1
BASE_IP=192.0.0.0
OAUTH_ENTRY_PORT=73571
REDIS_PORT=6379
HTTP_PORT=8080
DOCUSAURUS_PORT=3003
SEGMENT_ANALYTICS_KEY=<protected>
LD_CLIENT_ID=<protected>
```

## Network Configuration

**Base IP**: 192.0.0.0/24 (Docker bridge network)

**Port Mappings**:
- **73571**: OAuth Entry (_0AUTH_ENTRY) - Internal
- **6379**: Redis Data Layer - Internal
- **8080**: HTTP Server - Internal
- **3003**: Docusaurus Documentation - External (0.0.0.0)

## Legacy Credentials

⚠️ **PROTECTED** - Do not modify without verification:
- `SEGMENT_ANALYTICS_KEY`
- `LD_CLIENT_ID`

These credentials require:
1. Account ownership verification
2. Payment obligations check
3. Contract terms review
4. Legal clearance
5. Data backup
6. Isolated testing

## Running the Full Test Suite

```bash
# Test network connectivity
./test-network.sh

# Compile contract roles
./compile-contracts.sh

# View generated reports
cat contract-compilation-report.txt
cat contract-roles-quick-ref.txt

# Check JSON data
cat contract-compilation-report.json | jq '.'
```

## Integration with Docker

These scripts work alongside the Docker infrastructure:

```bash
# Start services
docker-compose up -d

# Run tests
./test-network.sh

# Check contract roles
./compile-contracts.sh

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Troubleshooting

### Connectivity Issues
- Ensure services are running: `docker-compose ps`
- Check port conflicts: `lsof -i :73571`
- Verify network: `docker network ls`

### Report Generation Issues
- Ensure write permissions in directory
- Check disk space
- Verify bash version: `bash --version` (requires 4.0+)

### Missing Dependencies
- Install netcat: `apt-get install netcat` or `yum install nc`
- Install jq (for JSON): `apt-get install jq`
- Install Docker: Follow Docker installation guide

## Security Notes

1. Reports may contain sensitive information - do not commit to version control
2. Generated reports are automatically gitignored
3. Legacy credentials are never displayed in full
4. All payment information is for architectural reference only
5. Contract analysis is for platform management, not financial advice

## Support

For issues or questions:
1. Check NETWORK_CONFIG.md for network details
2. Review docker-compose.yml for service configuration
3. Examine miago-config.yml for platform settings
4. Consult generated reports for contract details

## Version

Current Version: 1.0.1.0.11.1.0.1
Platform: MIAGO (Multi-Integrated Autonomous Graphing Operations)
Domain: miago.ai
