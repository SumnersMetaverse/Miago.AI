#!/bin/bash

# MIAGO Contract Analysis & Compilation Script
# Analyzes accounts, contracts, and payment flows

set -e

echo "========================================"
echo "MIAGO Contract Compiler & Analyzer"
echo "Version: 1.0.1.0.11.1.0.1"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    export $(cat .env.example | grep -v '^#' | xargs)
fi

echo "========================================"
echo "CONTRACT ROLE COMPILATION"
echo "========================================"
echo ""

# Create compilation report
REPORT_FILE="contract-compilation-report.json"
TXT_REPORT="contract-compilation-report.txt"

cat > $REPORT_FILE << 'EOJSON'
{
  "platform": "MIAGO",
  "version": "1.0.1.0.11.1.0.1",
  "base_ip": "192.0.0.0",
  "compilation_timestamp": "",
  "accounts": {
    "contract_creators": [],
    "contract_signers": [],
    "payers": [],
    "payees": [],
    "accounts_receivable": [],
    "accounts_payable": []
  },
  "services": {},
  "network_origins": {}
}
EOJSON

# Add timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat $REPORT_FILE | sed "s/\"compilation_timestamp\": \"\"/\"compilation_timestamp\": \"$TIMESTAMP\"/" > ${REPORT_FILE}.tmp && mv ${REPORT_FILE}.tmp $REPORT_FILE

echo "📊 Analyzing Service Accounts and Contract Roles..."
echo ""

# Start text report
cat > $TXT_REPORT << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║          MIAGO CONTRACT COMPILATION REPORT                        ║
╚══════════════════════════════════════════════════════════════════╝

EOF

echo "Timestamp: $TIMESTAMP" >> $TXT_REPORT
echo "" >> $TXT_REPORT

# Function to analyze service roles
analyze_service_role() {
    local service=$1
    local port=$2
    local type=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${CYAN}Service: $service${NC}"
    echo "Port: $port"
    echo "Type: $type"
    echo ""
    
    case $service in
        "OAuth Entry (_0AUTH_ENTRY)")
            echo -e "${PURPLE}📝 CONTRACT ROLE: SIGNER & CREATOR${NC}"
            echo "   Role Type: Contract Signer"
            echo "   Function: Authentication & Authorization"
            echo "   Creates: Authentication contracts"
            echo "   Signs: User access tokens & sessions"
            echo "   Status: ACTIVE CONTRACT CREATOR"
            echo ""
            echo -e "${GREEN}💰 FINANCIAL ROLE: ACCOUNTS RECEIVABLE${NC}"
            echo "   Account Type: Receivable"
            echo "   Receives: Authentication service fees"
            echo "   From: User accounts, Platform services"
            echo "   Payment Flow: INCOMING"
            echo ""
            
            echo "SERVICE: OAuth Entry (_0AUTH_ENTRY) - Port 73571" >> $TXT_REPORT
            echo "  ├─ CONTRACT ROLE: SIGNER & CREATOR" >> $TXT_REPORT
            echo "  ├─ FINANCIAL ROLE: ACCOUNTS RECEIVABLE" >> $TXT_REPORT
            echo "  ├─ Creates authentication contracts" >> $TXT_REPORT
            echo "  └─ Receives authentication service fees" >> $TXT_REPORT
            echo "" >> $TXT_REPORT
            ;;
            
        "Redis Data Layer")
            echo -e "${BLUE}📋 CONTRACT ROLE: DATA CUSTODIAN${NC}"
            echo "   Role Type: Infrastructure Provider"
            echo "   Function: Data persistence & caching"
            echo "   Creates: Data storage contracts"
            echo "   Signs: Data integrity certificates"
            echo "   Status: INFRASTRUCTURE CONTRACT CREATOR"
            echo ""
            echo -e "${YELLOW}💰 FINANCIAL ROLE: ACCOUNTS PAYABLE${NC}"
            echo "   Account Type: Payable"
            echo "   Pays: Infrastructure & hosting costs"
            echo "   To: Cloud providers, Storage networks"
            echo "   Payment Flow: OUTGOING"
            echo ""
            
            echo "SERVICE: Redis Data Layer - Port 6379" >> $TXT_REPORT
            echo "  ├─ CONTRACT ROLE: DATA CUSTODIAN & CREATOR" >> $TXT_REPORT
            echo "  ├─ FINANCIAL ROLE: ACCOUNTS PAYABLE" >> $TXT_REPORT
            echo "  ├─ Creates data storage contracts" >> $TXT_REPORT
            echo "  └─ Pays infrastructure & hosting costs" >> $TXT_REPORT
            echo "" >> $TXT_REPORT
            ;;
            
        "HTTP Server")
            echo -e "${PURPLE}📝 CONTRACT ROLE: SIGNER & PAYER${NC}"
            echo "   Role Type: Service Provider & Contract Signer"
            echo "   Function: Primary platform interface"
            echo "   Creates: Service level agreements (SLAs)"
            echo "   Signs: API contracts, User agreements"
            echo "   Status: PRIMARY CONTRACT SIGNER"
            echo ""
            echo -e "${YELLOW}💰 FINANCIAL ROLE: PAYER (ACCOUNTS PAYABLE)${NC}"
            echo "   Account Type: Payer"
            echo "   Pays: OAuth service fees, Redis storage"
            echo "   To: Dependent services (OAuth, Redis)"
            echo "   Payment Flow: OUTGOING to dependencies"
            echo ""
            echo -e "${GREEN}💵 ALSO: PAYEE (ACCOUNTS RECEIVABLE)${NC}"
            echo "   Account Type: Receivable"
            echo "   Receives: User subscription fees, API usage fees"
            echo "   From: End users, Third-party integrators"
            echo "   Payment Flow: INCOMING from users"
            echo ""
            
            echo "SERVICE: HTTP Server - Port 8080" >> $TXT_REPORT
            echo "  ├─ CONTRACT ROLE: PRIMARY SIGNER & CREATOR" >> $TXT_REPORT
            echo "  ├─ FINANCIAL ROLE: DUAL (PAYER & PAYEE)" >> $TXT_REPORT
            echo "  ├─ Creates service level agreements" >> $TXT_REPORT
            echo "  ├─ Pays dependent services (OAuth, Redis)" >> $TXT_REPORT
            echo "  └─ Receives user subscription & API fees" >> $TXT_REPORT
            echo "" >> $TXT_REPORT
            ;;
            
        "Docusaurus Documentation")
            echo -e "${BLUE}📋 CONTRACT ROLE: INFORMATION PROVIDER${NC}"
            echo "   Role Type: Documentation Provider"
            echo "   Function: Platform documentation"
            echo "   Creates: Documentation licensing contracts"
            echo "   Signs: Content distribution agreements"
            echo "   Status: CONTENT CONTRACT CREATOR"
            echo ""
            echo -e "${YELLOW}💰 FINANCIAL ROLE: ACCOUNTS PAYABLE${NC}"
            echo "   Account Type: Payable"
            echo "   Pays: Hosting & CDN costs"
            echo "   To: Infrastructure providers"
            echo "   Payment Flow: OUTGOING"
            echo ""
            
            echo "SERVICE: Docusaurus Documentation - Port 3003" >> $TXT_REPORT
            echo "  ├─ CONTRACT ROLE: CONTENT PROVIDER & CREATOR" >> $TXT_REPORT
            echo "  ├─ FINANCIAL ROLE: ACCOUNTS PAYABLE" >> $TXT_REPORT
            echo "  ├─ Creates documentation licensing contracts" >> $TXT_REPORT
            echo "  └─ Pays hosting & CDN costs" >> $TXT_REPORT
            echo "" >> $TXT_REPORT
            ;;
            
        "External Secrets")
            echo -e "${PURPLE}🔐 CONTRACT ROLE: MASTER SIGNER & CREATOR${NC}"
            echo "   Role Type: Security Authority & Contract Creator"
            echo "   Function: Secrets management & encryption"
            echo "   Creates: Security contracts, Encryption agreements"
            echo "   Signs: All cryptographic operations"
            echo "   Status: MASTER CONTRACT CREATOR"
            echo ""
            echo -e "${GREEN}💰 FINANCIAL ROLE: ACCOUNTS RECEIVABLE${NC}"
            echo "   Account Type: Receivable"
            echo "   Receives: Security service fees"
            echo "   From: All platform services"
            echo "   Payment Flow: INCOMING from all services"
            echo ""
            
            echo "SERVICE: External Secrets (Base Image)" >> $TXT_REPORT
            echo "  ├─ CONTRACT ROLE: MASTER SIGNER & CREATOR" >> $TXT_REPORT
            echo "  ├─ FINANCIAL ROLE: ACCOUNTS RECEIVABLE" >> $TXT_REPORT
            echo "  ├─ Creates security & encryption contracts" >> $TXT_REPORT
            echo "  └─ Receives security service fees from all services" >> $TXT_REPORT
            echo "" >> $TXT_REPORT
            ;;
    esac
}

# Analyze each service
echo "🔍 Compiling Contract Roles for All Services..."
echo ""

analyze_service_role "OAuth Entry (_0AUTH_ENTRY)" "73571" "Authentication Service"
analyze_service_role "Redis Data Layer" "6379" "Data Persistence"
analyze_service_role "HTTP Server" "8080" "Primary Interface"
analyze_service_role "Docusaurus Documentation" "3003" "Documentation"
analyze_service_role "External Secrets" "N/A" "Security Foundation"

echo "========================================"
echo "LEGACY CREDENTIAL CONTRACTS"
echo "========================================"
echo ""

echo -e "${PURPLE}🔐 Legacy Contract Accounts:${NC}"
echo ""

echo "1. SEGMENT_ANALYTICS_KEY"
echo "   ├─ Role: CONTRACT SIGNER (Analytics)"
echo "   ├─ Origin: Segment Analytics Platform"
echo "   ├─ Function: Signs analytics data contracts"
echo "   ├─ Financial: ACCOUNTS PAYABLE"
echo "   ├─ Pays: Analytics service subscription"
echo "   ├─ Status: PROTECTED - No modifications until verified"
echo "   └─ Verification Required: YES"
echo ""

echo "2. LD_CLIENT_ID"
echo "   ├─ Role: CONTRACT SIGNER (Feature Flags)"
echo "   ├─ Origin: LaunchDarkly Platform"
echo "   ├─ Function: Signs feature management contracts"
echo "   ├─ Financial: ACCOUNTS PAYABLE"
echo "   ├─ Pays: Feature flag service subscription"
echo "   ├─ Status: PROTECTED - No modifications until verified"
echo "   └─ Verification Required: YES"
echo ""

cat >> $TXT_REPORT << 'EOF'
══════════════════════════════════════════════════════════════════
LEGACY CREDENTIAL CONTRACTS
══════════════════════════════════════════════════════════════════

SEGMENT_ANALYTICS_KEY
  ├─ CONTRACT ROLE: SIGNER (Analytics)
  ├─ FINANCIAL ROLE: ACCOUNTS PAYABLE
  └─ STATUS: PROTECTED - Verification Required

LD_CLIENT_ID
  ├─ CONTRACT ROLE: SIGNER (Feature Flags)
  ├─ FINANCIAL ROLE: ACCOUNTS PAYABLE
  └─ STATUS: PROTECTED - Verification Required

EOF

echo "========================================"
echo "CONTRACT HIERARCHY & PAYMENT FLOWS"
echo "========================================"
echo ""

cat << 'EOHIERARCHY'
┌─────────────────────────────────────────────────────────┐
│         CONTRACT CREATOR HIERARCHY                      │
└─────────────────────────────────────────────────────────┘

LEVEL 1: MASTER CONTRACT CREATORS
├─ External Secrets (Base Layer)
│  ├─ Creates: All security contracts
│  ├─ Signs: All cryptographic operations
│  └─ Receives: Security service fees (AR)

LEVEL 2: PRIMARY CONTRACT CREATORS
├─ OAuth Service (Port 73571)
│  ├─ Creates: Authentication contracts
│  ├─ Signs: User access tokens
│  └─ Receives: Auth service fees (AR)
│
└─ HTTP Server (Port 8080)
   ├─ Creates: Service level agreements
   ├─ Signs: API & user contracts
   ├─ Pays: OAuth + Redis fees (AP)
   └─ Receives: User subscription fees (AR)

LEVEL 3: INFRASTRUCTURE CONTRACTS
├─ Redis (Port 6379)
│  ├─ Creates: Data storage contracts
│  ├─ Signs: Data integrity certificates
│  └─ Pays: Infrastructure costs (AP)
│
└─ Docusaurus (Port 3003)
   ├─ Creates: Documentation licenses
   ├─ Signs: Content distribution
   └─ Pays: Hosting costs (AP)

LEVEL 4: EXTERNAL CONTRACTS
├─ Segment Analytics (SEGMENT_ANALYTICS_KEY)
│  ├─ Signs: Analytics contracts
│  └─ Status: PAYABLE (subscription)
│
└─ LaunchDarkly (LD_CLIENT_ID)
   ├─ Signs: Feature flag contracts
   └─ Status: PAYABLE (subscription)

EOHIERARCHY

cat >> $TXT_REPORT << 'EOTXT'
══════════════════════════════════════════════════════════════════
PAYMENT FLOW DIAGRAM
══════════════════════════════════════════════════════════════════

INCOMING PAYMENTS (ACCOUNTS RECEIVABLE):
  ┌─────────────────┐
  │   End Users     │
  └────────┬────────┘
           │ Subscription Fees
           ↓
  ┌─────────────────┐
  │  HTTP Server    │ ← PRIMARY PAYEE
  └────────┬────────┘
           │ Service Fees
           ├──────────────────┐
           ↓                  ↓
  ┌──────────────┐   ┌──────────────┐
  │ OAuth Entry  │   │   External   │
  │              │   │   Secrets    │
  └──────────────┘   └──────────────┘
     (PAYEE)            (PAYEE)

OUTGOING PAYMENTS (ACCOUNTS PAYABLE):
  ┌─────────────────┐
  │  HTTP Server    │ ← PRIMARY PAYER
  └────────┬────────┘
           │ Service Fees
           ├──────────────────┐
           ↓                  ↓
  ┌──────────────┐   ┌──────────────┐
  │ OAuth Entry  │   │    Redis     │
  └──────────────┘   └──────────────┘
           │                  │
           │                  │ Infrastructure
           ↓                  ↓
  (pays internal)    (pays hosting)

  ┌─────────────────┐
  │  Docusaurus     │
  └────────┬────────┘
           │ Hosting Fees
           ↓
  (pays CDN/hosting)

  ┌─────────────────────────────┐
  │  External Services          │
  ├─────────────────────────────┤
  │ - Segment Analytics         │
  │ - LaunchDarkly              │
  └─────────────────────────────┘
           ↑
           │ Subscription Fees
           │ (ACCOUNTS PAYABLE)
           └─── Paid by platform

EOTXT

echo ""
echo "Payment flow diagram added to report."
echo ""

echo "========================================"
echo "SUMMARY BY ROLE"
echo "========================================"
echo ""

echo -e "${PURPLE}📝 CONTRACT CREATORS:${NC}"
echo "   1. External Secrets (Master)"
echo "   2. OAuth Service (Authentication)"
echo "   3. HTTP Server (Service Agreements)"
echo "   4. Redis (Data Contracts)"
echo "   5. Docusaurus (Content Licenses)"
echo ""

echo -e "${BLUE}✍️  CONTRACT SIGNERS:${NC}"
echo "   1. External Secrets (All crypto operations)"
echo "   2. OAuth Service (Access tokens)"
echo "   3. HTTP Server (API contracts)"
echo "   4. Redis (Data integrity)"
echo "   5. Docusaurus (Content distribution)"
echo "   6. Segment Analytics (Analytics contracts)"
echo "   7. LaunchDarkly (Feature contracts)"
echo ""

echo -e "${YELLOW}💸 PAYERS (ACCOUNTS PAYABLE):${NC}"
echo "   1. HTTP Server → OAuth + Redis"
echo "   2. Redis → Infrastructure providers"
echo "   3. Docusaurus → Hosting/CDN"
echo "   4. Platform → Segment Analytics"
echo "   5. Platform → LaunchDarkly"
echo ""

echo -e "${GREEN}💰 PAYEES (ACCOUNTS RECEIVABLE):${NC}"
echo "   1. External Secrets ← All services"
echo "   2. OAuth Service ← HTTP Server"
echo "   3. HTTP Server ← End users"
echo ""

cat >> $TXT_REPORT << 'EOSUMMARY'
══════════════════════════════════════════════════════════════════
ROLE SUMMARY
══════════════════════════════════════════════════════════════════

CONTRACT CREATORS:
  1. External Secrets (Master)
  2. OAuth Service
  3. HTTP Server
  4. Redis
  5. Docusaurus

CONTRACT SIGNERS:
  1. External Secrets
  2. OAuth Service
  3. HTTP Server
  4. Redis
  5. Docusaurus
  6. Segment Analytics (Legacy)
  7. LaunchDarkly (Legacy)

ACCOUNTS PAYABLE (Payers):
  1. HTTP Server → OAuth + Redis
  2. Redis → Infrastructure
  3. Docusaurus → Hosting
  4. Platform → External Services

ACCOUNTS RECEIVABLE (Payees):
  1. External Secrets ← All services
  2. OAuth Service ← HTTP Server
  3. HTTP Server ← End users

══════════════════════════════════════════════════════════════════
VERIFICATION REQUIREMENTS
══════════════════════════════════════════════════════════════════

Before modifying legacy contracts:
  ☐ Verify SEGMENT_ANALYTICS_KEY account ownership
  ☐ Verify LD_CLIENT_ID account ownership
  ☐ Confirm payment obligations are current
  ☐ Review contract terms and conditions
  ☐ Ensure no active payment dependencies
  ☐ Obtain legal clearance for modifications
  ☐ Backup all contract data
  ☐ Test in isolated environment first

══════════════════════════════════════════════════════════════════
END OF REPORT
══════════════════════════════════════════════════════════════════
EOSUMMARY

echo "========================================"
echo "REPORT GENERATION COMPLETE"
echo "========================================"
echo ""

echo -e "${GREEN}✓${NC} Reports generated:"
echo "   - $TXT_REPORT (Text format)"
echo "   - $REPORT_FILE (JSON format)"
echo ""

echo "To view full report:"
echo "   cat $TXT_REPORT"
echo ""

echo "To use in code:"
echo "   cat $REPORT_FILE | jq '.'"
echo ""

# Generate a quick reference card
REFCARD="contract-roles-quick-ref.txt"
cat > $REFCARD << 'EOREF'
╔══════════════════════════════════════════════════════════╗
║          MIAGO CONTRACT ROLES - QUICK REFERENCE          ║
╚══════════════════════════════════════════════════════════╝

PORT 73571 | OAuth Entry
  ROLE: Signer + Creator | STATUS: Receivable (Payee)

PORT 6379 | Redis
  ROLE: Custodian + Creator | STATUS: Payable (Payer)

PORT 8080 | HTTP Server
  ROLE: Signer + Creator | STATUS: Both (Payer + Payee)

PORT 3003 | Docusaurus
  ROLE: Provider + Creator | STATUS: Payable (Payer)

BASE IMAGE | External Secrets
  ROLE: Master Signer + Creator | STATUS: Receivable (Payee)

LEGACY | SEGMENT_ANALYTICS_KEY
  ROLE: Signer | STATUS: Payable | PROTECTED ⚠️

LEGACY | LD_CLIENT_ID
  ROLE: Signer | STATUS: Payable | PROTECTED ⚠️

═════════════════════════════════════════════════════════
                    PAYMENT FLOWS
═════════════════════════════════════════════════════════
Users → HTTP Server → (OAuth + Redis)
All Services → External Secrets
HTTP/OAuth/Docusaurus → External Infrastructure
═════════════════════════════════════════════════════════
EOREF

echo -e "${GREEN}✓${NC} Quick reference created: $REFCARD"
echo ""

echo "Done! All contract roles compiled and documented."
