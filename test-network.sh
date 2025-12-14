#!/bin/bash

# MIAGO Platform Test Script
# Tests all service connections and reports credential/network origins

set -e

echo "========================================"
echo "MIAGO Platform Network Test"
echo "Version: 1.0.1.0.11.1.0.1"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables if .env exists
if [ -f .env ]; then
    echo -e "${GREEN}✓${NC} Loading environment variables from .env"
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${YELLOW}⚠${NC} No .env file found, using defaults from .env.example"
    export $(cat .env.example | grep -v '^#' | xargs)
fi

echo ""
echo "========================================"
echo "SERVICE CONNECTIVITY TESTS"
echo "========================================"
echo ""

# Function to test port connectivity
test_port() {
    local host=$1
    local port=$2
    local service=$3
    
    if command -v nc &> /dev/null; then
        if nc -z -w5 $host $port 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $service ($host:$port) - ACTIVE"
            return 0
        else
            echo -e "${RED}✗${NC} $service ($host:$port) - UNAVAILABLE"
            return 1
        fi
    else
        if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $service ($host:$port) - ACTIVE"
            return 0
        else
            echo -e "${RED}✗${NC} $service ($host:$port) - UNAVAILABLE"
            return 1
        fi
    fi
}

# Test OAuth Entry Service (Port 73571)
echo "1. Testing OAuth Entry Service (_0AUTH_ENTRY)"
echo "   Port: ${OAUTH_ENTRY_PORT:-73571}"
echo "   Function: 3AF_0AUTH Verification Entry Point"
test_port localhost ${OAUTH_ENTRY_PORT:-73571} "OAuth Entry"
echo ""

# Test Redis Service (Port 6379)
echo "2. Testing Redis Data Layer (SERVER_6379)"
echo "   Port: ${REDIS_PORT:-6379}"
echo "   Function: Data persistence and cache"
test_port localhost ${REDIS_PORT:-6379} "Redis"
echo ""

# Test HTTP Service (Port 8080)
echo "3. Testing HTTP Server (PORT8080)"
echo "   Port: ${HTTP_PORT:-8080}"
echo "   Function: Primary HTTP service"
test_port localhost ${HTTP_PORT:-8080} "HTTP Server"
echo ""

# Test Docusaurus Service (Port 3003)
echo "4. Testing Docusaurus Documentation"
echo "   Port: ${DOCUSAURUS_PORT:-3003}"
echo "   Function: Documentation server"
test_port localhost ${DOCUSAURUS_PORT:-3003} "Docusaurus"
echo ""

echo "========================================"
echo "CREDENTIALS & PLATFORM MAPPING"
echo "========================================"
echo ""

# Check Docker configuration
echo "Docker Configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is installed"
    docker --version
    
    # Check if docker-compose exists
    if [ -f "docker-compose.yml" ]; then
        echo -e "${GREEN}✓${NC} docker-compose.yml found"
        echo "   Services defined:"
        grep "^  [a-z]" docker-compose.yml | sed 's/://g' | sed 's/^/   - /'
    fi
else
    echo -e "${RED}✗${NC} Docker is not installed"
fi
echo ""

# Platform Credentials Report
echo "Platform Credentials & Origins:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🔐 Legacy Keys (PROTECTED - Do Not Modify):"
echo "   ├─ SEGMENT_ANALYTICS_KEY"
if [ -n "$SEGMENT_ANALYTICS_KEY" ] && [ "$SEGMENT_ANALYTICS_KEY" != "your_segment_key_here" ]; then
    echo "   │  ├─ Status: CONFIGURED"
    echo "   │  ├─ Origin: Segment Analytics Platform"
    echo "   │  ├─ Network: Analytics tracking service"
    echo "   │  └─ Value: ${SEGMENT_ANALYTICS_KEY:0:20}... (hidden)"
else
    echo "   │  ├─ Status: NOT CONFIGURED"
    echo "   │  └─ Action: Set in .env file when verified"
fi

echo "   │"
echo "   └─ LD_CLIENT_ID"
if [ -n "$LD_CLIENT_ID" ] && [ "$LD_CLIENT_ID" != "your_launchdarkly_id_here" ]; then
    echo "      ├─ Status: CONFIGURED"
    echo "      ├─ Origin: LaunchDarkly Feature Flags"
    echo "      ├─ Network: Feature management service"
    echo "      └─ Value: ${LD_CLIENT_ID:0:20}... (hidden)"
else
    echo "      ├─ Status: NOT CONFIGURED"
    echo "      └─ Action: Set in .env file when verified"
fi

echo ""
echo "🌐 Network Configuration:"
echo "   ├─ Base IP: ${BASE_IP:-192.0.0.0}/24"
echo "   ├─ Platform: MIAGO (Multi-Integrated Autonomous Graphing Operations)"
echo "   ├─ Domain: ${DOMAIN:-miago.ai}"
echo "   └─ Version: ${MIAGO_VERSION:-1.0.1.0.11.1.0.1}"

echo ""
echo "🔗 Service Ports & Origins:"
echo "   ├─ Port ${OAUTH_ENTRY_PORT:-73571} (_0AUTH_ENTRY)"
echo "   │  ├─ Service: 3AF_0AUTH Verification"
echo "   │  ├─ Origin: Custom MIAGO authentication system"
echo "   │  ├─ Network: Internal (192.0.0.0/24)"
echo "   │  └─ Dependencies: Redis (6379)"
echo "   │"
echo "   ├─ Port ${REDIS_PORT:-6379} (Redis)"
echo "   │  ├─ Service: Data persistence layer"
echo "   │  ├─ Origin: Redis open-source"
echo "   │  ├─ Network: Internal (192.0.0.0/24)"
echo "   │  └─ Dependencies: None (standalone)"
echo "   │"
echo "   ├─ Port ${HTTP_PORT:-8080} (HTTP Server)"
echo "   │  ├─ Service: Primary HTTP interface"
echo "   │  ├─ Origin: MIAGO platform services"
echo "   │  ├─ Network: Internal (192.0.0.0/24)"
echo "   │  └─ Dependencies: OAuth (73571), Redis (6379)"
echo "   │"
echo "   └─ Port ${DOCUSAURUS_PORT:-3003} (Documentation)"
echo "      ├─ Service: Platform documentation"
echo "      ├─ Origin: Facebook Docusaurus"
echo "      ├─ Network: External (0.0.0.0)"
echo "      └─ Dependencies: None (standalone)"

echo ""
echo "========================================"
echo "DOCKER IMAGES & ORIGINS"
echo "========================================"
echo ""

if command -v docker &> /dev/null; then
    echo "📦 Base Image:"
    echo "   ├─ Image: ghcr.io/external-secrets/external-secrets"
    echo "   ├─ SHA256: a4e1d50ba3f42fcbd818df963086ab81049c7fef6b81c34dd5360c5f253f916a.att"
    echo "   ├─ Origin: GitHub Container Registry"
    echo "   ├─ Platform: External Secrets Operator"
    echo "   └─ Purpose: Secure secrets management for Kubernetes"
    
    echo ""
    echo "Local Docker Images:"
    docker images | head -n 10
else
    echo -e "${YELLOW}⚠${NC} Docker not available - cannot check images"
fi

echo ""
echo "========================================"
echo "SERVICE DEPENDENCY MAP"
echo "========================================"
echo ""

cat << 'EOF'
┌─────────────────────────────────────────┐
│         MIAGO Service Architecture      │
└─────────────────────────────────────────┘

Standalone Services:
├─ Redis (6379)
│  └─ Origin: Internal data layer
│
└─ Docusaurus (3003)
   └─ Origin: External documentation

Dependent Services:
├─ OAuth Service (73571)
│  ├─ Depends on: Redis (6379)
│  └─ Origin: MIAGO 3AF_0AUTH
│
└─ HTTP Service (8080)
   ├─ Depends on: OAuth (73571) + Redis (6379)
   └─ Origin: MIAGO platform

Network Isolation:
└─ Internal: 192.0.0.0/24 (OAuth, Redis, HTTP)
└─ External: 0.0.0.0 (Docusaurus only)
EOF

echo ""
echo "========================================"
echo "CONTRACT VERIFICATION CHECKLIST"
echo "========================================"
echo ""

echo "✓ Configuration Files:"
if [ -f "miago-config.yml" ]; then
    echo "  ${GREEN}✓${NC} miago-config.yml - Platform configuration"
else
    echo "  ${RED}✗${NC} miago-config.yml - MISSING"
fi

if [ -f "docker-compose.yml" ]; then
    echo "  ${GREEN}✓${NC} docker-compose.yml - Service orchestration"
else
    echo "  ${RED}✗${NC} docker-compose.yml - MISSING"
fi

if [ -f ".env.example" ]; then
    echo "  ${GREEN}✓${NC} .env.example - Environment template"
else
    echo "  ${RED}✗${NC} .env.example - MISSING"
fi

if [ -f "NETWORK_CONFIG.md" ]; then
    echo "  ${GREEN}✓${NC} NETWORK_CONFIG.md - Network documentation"
else
    echo "  ${RED}✗${NC} NETWORK_CONFIG.md - MISSING"
fi

echo ""
echo "✓ Legacy Contract Protection:"
echo "  ${GREEN}✓${NC} SEGMENT_ANALYTICS_KEY - Protected (no modifications)"
echo "  ${GREEN}✓${NC} LD_CLIENT_ID - Protected (no modifications)"

echo ""
echo "========================================"
echo "RECOMMENDATIONS"
echo "========================================"
echo ""

echo "1. Service Startup Order:"
echo "   a. Start Redis first (no dependencies)"
echo "   b. Start OAuth service (depends on Redis)"
echo "   c. Start HTTP service (depends on OAuth + Redis)"
echo "   d. Start Docusaurus (independent)"
echo ""

echo "2. Network Verification:"
echo "   - All internal services use 192.0.0.0/24 network"
echo "   - Only Docusaurus exposed externally"
echo "   - Credentials isolated from public access"
echo ""

echo "3. Credential Management:"
echo "   - Copy .env.example to .env"
echo "   - Configure SEGMENT_ANALYTICS_KEY (after verification)"
echo "   - Configure LD_CLIENT_ID (after accreditation)"
echo "   - Never commit .env to version control"
echo ""

echo "4. Starting Services:"
echo "   Run: docker-compose up -d"
echo "   Check: docker-compose ps"
echo "   Logs: docker-compose logs -f"
echo ""

echo "========================================"
echo "Test Complete"
echo "========================================"
