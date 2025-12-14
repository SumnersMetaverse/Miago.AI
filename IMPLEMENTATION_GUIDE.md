# MIAGO Platform Implementation Guide
## Step-by-Step Instructions for Correct Order of Operations

**Version**: 1.0.1.0.11.1.0.1  
**Platform**: MIAGO (Multi-Integrated Autonomous Graphing Operations)  
**Date**: 2025-12-14

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Phase 1: Initial Setup](#phase-1-initial-setup)
3. [Phase 2: Service Configuration](#phase-2-service-configuration)
4. [Phase 3: Network Deployment](#phase-3-network-deployment)
5. [Phase 4: Testing & Verification](#phase-4-testing--verification)
6. [Phase 5: Contract Validation](#phase-5-contract-validation)
7. [RPC Integration](#rpc-integration)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- [ ] Docker (version 20.10+)
- [ ] Docker Compose (version 1.29+)
- [ ] Node.js (version 18+)
- [ ] Git
- [ ] Bash shell (for scripts)

### Required Files
- [ ] `.env` file (copy from `.env.example`)
- [ ] `docker-compose.yml`
- [ ] `Dockerfile`
- [ ] `miago-config.yml`
- [ ] Network testing scripts

### Verification Commands
```bash
# Check Docker
docker --version
docker-compose --version

# Check Node.js
node --version
npm --version

# Check Git
git --version
```

---

## Phase 1: Initial Setup

### Step 1.1: Clone and Navigate to Repository
```bash
# Navigate to project directory
cd /path/to/Miago.AI

# Verify you're in the correct directory
ls -la | grep -E "(Dockerfile|docker-compose)"
```

### Step 1.2: Configure Environment Variables
```bash
# Copy environment template
cp .env.example .env

# Edit the .env file
nano .env
```

**Required Variables to Configure:**
```bash
# Platform Configuration
MIAGO_VERSION=1.0.1.0.11.1.0.1
BASE_IP=192.0.0.0
PLATFORM_NAME=MIAGO
DOMAIN=miago.ai

# Port Configuration
OAUTH_ENTRY_PORT=73571
REDIS_PORT=6379
HTTP_PORT=8080
DOCUSAURUS_PORT=3003

# Legacy Keys (DO NOT MODIFY until verified)
# SEGMENT_ANALYTICS_KEY=<leave_empty_until_verified>
# LD_CLIENT_ID=<leave_empty_until_verified>
```

**⚠️ IMPORTANT**: Do NOT set legacy keys until accounts are verified and accredited.

### Step 1.3: Verify Configuration Files
```bash
# Check all required files exist
for file in Dockerfile docker-compose.yml miago-config.yml .env NETWORK_CONFIG.md; do
    if [ -f "$file" ]; then
        echo "✓ $file found"
    else
        echo "✗ $file MISSING"
    fi
done
```

---

## Phase 2: Service Configuration

### Step 2.1: Review Service Architecture
```bash
# View the platform configuration
cat miago-config.yml

# View service dependencies
cat docker-compose.yml
```

### Step 2.2: Understand Service Dependencies
**Correct Startup Order:**

1. **Redis** (Port 6379) - No dependencies
2. **OAuth Entry** (Port 73571) - Depends on Redis
3. **HTTP Server** (Port 8080) - Depends on OAuth + Redis
4. **Docusaurus** (Port 3003) - Standalone

### Step 2.3: Verify Port Availability
```bash
# Check if ports are available
for port in 73571 6379 8080 3003; do
    if lsof -i :$port > /dev/null 2>&1; then
        echo "✗ Port $port is IN USE"
    else
        echo "✓ Port $port is AVAILABLE"
    fi
done
```

**If ports are in use:**
```bash
# Find what's using the port
lsof -i :73571
lsof -i :6379
lsof -i :8080
lsof -i :3003

# Stop the conflicting service or modify ports in docker-compose.yml
```

---

## Phase 3: Network Deployment

### Step 3.1: Build Docker Images
```bash
# Build the Docker image
docker-compose build

# Verify image was created
docker images | grep miago
```

**Expected output:**
```
miago-docs       latest    ...
miago-http       latest    ...
miago-oauth      latest    ...
```

### Step 3.2: Create Docker Network
```bash
# The network is created automatically by docker-compose
# Verify network configuration
docker network ls | grep miago
```

### Step 3.3: Start Services in Correct Order

**Option A: Start All Services Together (Recommended)**
```bash
# Start all services (handles dependencies automatically)
docker-compose up -d

# Verify all services started
docker-compose ps
```

**Option B: Start Services Manually (Advanced)**
```bash
# Step 1: Start Redis first
docker-compose up -d redis
sleep 5

# Step 2: Start OAuth service
docker-compose up -d oauth-service
sleep 5

# Step 3: Start HTTP service
docker-compose up -d http-service
sleep 5

# Step 4: Start Docusaurus
docker-compose up -d docusaurus
```

### Step 3.4: Verify Service Health
```bash
# Check container status
docker-compose ps

# View logs for all services
docker-compose logs

# View logs for specific service
docker-compose logs redis
docker-compose logs oauth-service
docker-compose logs http-service
docker-compose logs docusaurus
```

**Healthy Status Indicators:**
- All containers show "Up" status
- No error messages in logs
- Ports are properly mapped

---

## Phase 4: Testing & Verification

### Step 4.1: Run Network Connectivity Tests
```bash
# Make scripts executable (if not already)
chmod +x test-network.sh
chmod +x compile-contracts.sh

# Run network test
./test-network.sh
```

**Expected Results:**
- ✓ OAuth Entry (localhost:73571) - ACTIVE
- ✓ Redis (localhost:6379) - ACTIVE
- ✓ HTTP Server (localhost:8080) - ACTIVE
- ✓ Docusaurus (localhost:3003) - ACTIVE

### Step 4.2: Test Individual Services

**Test Redis:**
```bash
# Connect to Redis
docker exec -it miago-redis redis-cli ping
# Expected: PONG
```

**Test OAuth Service:**
```bash
# Check OAuth service is listening
curl -v http://localhost:73571/health || echo "Service starting..."
```

**Test HTTP Server:**
```bash
# Check HTTP service
curl -v http://localhost:8080/health || echo "Service starting..."
```

**Test Docusaurus:**
```bash
# Check documentation site
curl -s http://localhost:3003 | head -20
```

### Step 4.3: Verify Network Isolation
```bash
# Check Docker network
docker network inspect miago-network

# Verify IP range is 192.0.0.0/24
docker network inspect miago-network | grep Subnet
```

---

## Phase 5: Contract Validation

### Step 5.1: Run Contract Compilation
```bash
# Generate contract analysis
./compile-contracts.sh

# View generated reports
cat contract-compilation-report.txt
cat contract-roles-quick-ref.txt
```

### Step 5.2: Review Contract Roles
```bash
# Check contract creators
grep "CONTRACT CREATOR" contract-compilation-report.txt

# Check payers (Accounts Payable)
grep "ACCOUNTS PAYABLE" contract-compilation-report.txt

# Check payees (Accounts Receivable)
grep "ACCOUNTS RECEIVABLE" contract-compilation-report.txt
```

### Step 5.3: Validate Payment Flows
```bash
# Review payment flow diagram
cat contract-compilation-report.txt | grep -A 20 "PAYMENT FLOW"
```

### Step 5.4: Verify Legacy Credentials
```bash
# Ensure legacy keys are protected
grep -E "SEGMENT_ANALYTICS_KEY|LD_CLIENT_ID" .env

# Should show empty or placeholder values until verified
```

**⚠️ CRITICAL**: Do NOT set these values until:
1. Account ownership is verified
2. Payment obligations are confirmed current
3. Contract terms are reviewed
4. Legal clearance is obtained

---

## Phase 6: RPC Integration

### Step 6.1: Prepare RPC Configuration
If you have RPC cURLs, create a configuration file:

```bash
# Create RPC configuration file
cat > rpc-endpoints.yml << 'EOF'
rpc_endpoints:
  - name: "Primary RPC"
    url: "http://localhost:8545"
    network: "ethereum"
    
  - name: "Secondary RPC"
    url: "http://localhost:8546"
    network: "polygon"
    
  - name: "OAuth RPC"
    url: "http://localhost:73571/rpc"
    network: "miago_internal"
EOF
```

### Step 6.2: Test RPC Endpoints
```bash
# Test RPC connectivity (example)
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### Step 6.3: Configure RPC in Services
Add RPC endpoints to `.env`:
```bash
# Add to .env file
echo "RPC_PRIMARY_URL=http://localhost:8545" >> .env
echo "RPC_SECONDARY_URL=http://localhost:8546" >> .env
echo "RPC_OAUTH_URL=http://localhost:73571/rpc" >> .env
```

Then restart services:
```bash
docker-compose restart
```

---

## Phase 7: Monitoring and Maintenance

### Step 7.1: Monitor Service Health
```bash
# Continuous monitoring
watch -n 5 'docker-compose ps'

# View live logs
docker-compose logs -f

# Monitor specific service
docker-compose logs -f oauth-service
```

### Step 7.2: Resource Usage
```bash
# Check container resource usage
docker stats

# Check disk usage
docker system df
```

### Step 7.3: Backup Configuration
```bash
# Backup critical files
tar -czf miago-backup-$(date +%Y%m%d).tar.gz \
  .env \
  miago-config.yml \
  docker-compose.yml \
  NETWORK_CONFIG.md
```

---

## Troubleshooting

### Issue: Services Won't Start
```bash
# Check Docker daemon
systemctl status docker

# Check logs for errors
docker-compose logs

# Restart services
docker-compose down
docker-compose up -d
```

### Issue: Port Already in Use
```bash
# Find process using port
lsof -i :73571

# Kill process (use specific PID)
kill <PID>

# Or modify port in docker-compose.yml
```

### Issue: Network Connectivity Problems
```bash
# Reset Docker network
docker-compose down
docker network prune -f
docker-compose up -d

# Verify network
docker network inspect miago-network
```

### Issue: Container Keeps Restarting
```bash
# Check specific container logs
docker-compose logs <service-name>

# Check container status
docker inspect <container-name>

# Rebuild container
docker-compose build <service-name>
docker-compose up -d <service-name>
```

---

## Security Checklist

Before production deployment:

- [ ] All legacy keys verified and accredited
- [ ] .env file permissions set to 600 (read/write owner only)
- [ ] Firewall rules configured for internal network only
- [ ] External access limited to Docusaurus port (3003) only
- [ ] All passwords/tokens rotated and secured
- [ ] Backup procedures tested and verified
- [ ] Monitoring and alerting configured
- [ ] Disaster recovery plan documented

---

## Quick Reference Commands

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# View logs
docker-compose logs -f

# Restart a service
docker-compose restart <service-name>

# Rebuild a service
docker-compose build <service-name>

# Test network
./test-network.sh

# Analyze contracts
./compile-contracts.sh

# Check service health
docker-compose ps
```

---

## Support and Next Steps

1. Review NETWORK_CONFIG.md for detailed network architecture
2. Review TESTING_SCRIPTS.md for testing tool documentation
3. Run ./test-network.sh regularly to verify connectivity
4. Run ./compile-contracts.sh to audit contract roles
5. Monitor logs for any errors or warnings
6. Keep .env file backed up and secure

---

**Version History:**
- 1.0.1.0.11.1.0.1 - Initial implementation guide

**Last Updated:** 2025-12-14
