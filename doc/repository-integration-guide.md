# SumnersMetaverse Repository Integration Guide

> **⚠️ IMPORTANT NOTICE:**
> - This guide uses **YOUR EXISTING** Docker files and configurations from your repositories
> - Use **YOUR ACTUAL** credentials from Tenderly.co, your Redis repository, and Bitcoin Core
> - This documentation shows HOW to connect things, not WHAT credentials to use
> - See individual repository README files for specific configuration details

This document explains how to connect your various SumnersMetaverse repositories to your Bitcoin Core node and how to execute the code to run everything together.

## Overview of Your Repositories

Based on your GitHub account, here are the Bitcoin/blockchain-related repositories that need to be connected to your Bitcoin Core node:

### 1. **Miago.AI** (This Repository)
- **Purpose**: Bitcoin Core node integration with CLI tools and mempool.space
- **Status**: ✅ Configured with mempool.space integration documentation
- **Key Features**: Logout command, integration testing, compliance documentation

### 2. **lndhub** 
- **Purpose**: Lightning Network Hub - Wrapper for LND (Lightning Network Daemon) providing separate accounts for users
- **Needs**: Bitcoin Core + LND (Lightning Network Daemon)
- **Status**: ⚠️ Requires Bitcoin Core to be running with Lightning Network
- **Integration Point**: LND connects to Bitcoin Core, lndhub connects to LND

### 3. **3xplCore**
- **Purpose**: Universal blockchain explorer core modules (like mempool.space but supports multiple chains)
- **Needs**: Bitcoin Core node for Bitcoin blockchain data
- **Status**: ⚠️ Requires Bitcoin Core with RPC access
- **Integration Point**: Direct RPC connection to Bitcoin Core

### 4. **mining-pools**
- **Purpose**: Bitcoin mining pool identification and Coinbase tag data
- **Needs**: Read-only connection to Bitcoin Core for block data analysis
- **Status**: ⚠️ Requires Bitcoin Core with RPC access
- **Integration Point**: Read-only RPC access to Bitcoin Core

### 5. **Other Repositories** (Not directly connected to Bitcoin Core)
- `metamask-docs`, `provider-engine`, `aave-v4-sdk`, `dapp-near-ref-ui`, `filda` - These are for Ethereum/other chains
- These connect to their respective blockchain networks independently

---

## Complete Setup and Execution Guide

### Prerequisites

1. **Bitcoin Core**: Running and fully synced
2. **Docker & Docker Compose**: Installed and running
3. **Git**: For cloning repositories
4. **Node.js**: v18+ for JavaScript-based services
5. **Python 3**: For scripts and testing
6. **Go**: For CLI tools (this repository)

### Step 1: Setup Bitcoin Core (Foundation)

This is the base layer that everything else connects to.

#### 1.1 Configure Bitcoin Core

```bash
# Edit your bitcoin.conf
nano ~/.bitcoin/bitcoin.conf
```

Add these settings (use `contrib/mempool-space/bitcoin.conf.example` as reference):

```conf
# Basic settings
server=1
rest=1
txindex=1

# RPC authentication
rpcuser=your_rpc_username
rpcpassword=your_strong_password
rpcbind=127.0.0.1
rpcallowip=127.0.0.1

# Optional: ZMQ for real-time notifications
zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333
zmqpubhashblock=tcp://127.0.0.1:28334
```

#### 1.2 Start Bitcoin Core

```bash
# Start Bitcoin Core
bitcoind --daemon

# Verify it's running
bitcoin-cli getblockchaininfo

# Test the connection
cd contrib/mempool-space
python3 test-integration.py --user your_rpc_username --password your_strong_password
```

### Step 2: Setup Lightning Network (For lndhub)

#### 2.1 Install LND

```bash
# Download LND
wget https://github.com/lightningnetwork/lnd/releases/download/v0.17.0-beta/lnd-linux-amd64-v0.17.0-beta.tar.gz
tar -xzf lnd-linux-amd64-v0.17.0-beta.tar.gz
sudo install -m 0755 -o root -g root -t /usr/local/bin lnd-linux-amd64-v0.17.0-beta/*
```

#### 2.2 Configure LND

Create `~/.lnd/lnd.conf`:

```conf
[Application Options]
alias=YourNodeName
debuglevel=info

[Bitcoin]
bitcoin.active=1
bitcoin.mainnet=1
bitcoin.node=bitcoind

[Bitcoind]
bitcoind.rpchost=localhost:8332
bitcoind.rpcuser=your_rpc_username
bitcoind.rpcpass=your_strong_password
bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332
bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333
```

#### 2.3 Start LND

```bash
lnd &

# Create wallet (first time only)
lncli create

# Unlock wallet (subsequent starts)
lncli unlock
```

### Step 3: Setup lndhub

#### 3.1 Clone and Configure

```bash
cd ~/projects
git clone https://github.com/SumnersMetaverse/lndhub.git
cd lndhub

# Install dependencies
npm install
```

#### 3.2 Configure Environment

Create `.env` file:

```env
# LND Connection
LND_HOST=localhost:10009
LND_CERT_PATH=/home/username/.lnd/tls.cert
LND_MACAROON_PATH=/home/username/.lnd/data/chain/bitcoin/mainnet/admin.macaroon

# Redis (if using)
REDIS_HOST=your_redis_host
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# API Settings
PORT=3000
```

#### 3.3 Run lndhub

```bash
# Development
npm run dev

# Production
npm run build
npm start

# Or with Docker
docker-compose up -d
```

### Step 4: Setup 3xplCore

#### 4.1 Clone and Configure

```bash
cd ~/projects
git clone https://github.com/SumnersMetaverse/3xplCore.git
cd 3xplCore
```

#### 4.2 Configure for Bitcoin

Edit configuration file (check their README for specifics):

```json
{
  "bitcoin": {
    "rpc": {
      "host": "127.0.0.1",
      "port": 8332,
      "username": "your_rpc_username",
      "password": "your_strong_password"
    },
    "enabled": true
  }
}
```

#### 4.3 Run 3xplCore

```bash
# Follow their specific setup instructions
# Typically involves:
npm install
npm run build
npm start
```

### Step 5: Setup mining-pools

#### 5.1 Clone and Configure

```bash
cd ~/projects
git clone https://github.com/SumnersMetaverse/mining-pools.git
cd mining-pools
```

#### 5.2 Configure Bitcoin Core Connection

Create config file (check their README):

```json
{
  "bitcoinCore": {
    "rpc": {
      "host": "127.0.0.1",
      "port": 8332,
      "username": "your_rpc_username",
      "password": "your_strong_password"
    }
  }
}
```

#### 5.3 Run Analysis

```bash
# Install dependencies
npm install

# Run mining pool analysis
npm run analyze
```

### Step 6: Setup Redis (Optional but Recommended)

Many services use Redis for caching and session management.

```bash
# Install Redis
sudo apt-get install redis-server

# Or with Docker
docker run -d \
  --name redis \
  -p 6379:6379 \
  -v redis-data:/data \
  redis:alpine

# Secure Redis
redis-cli CONFIG SET requirepass "your_redis_password"
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Your Infrastructure                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌────────────────────────┐   │
│  │  Bitcoin Core    │◄────────│  mempool.space         │   │
│  │  (Foundation)    │         │  (via Miago.AI)        │   │
│  │                  │         └────────────────────────┘   │
│  │  - RPC: 8332     │                                        │
│  │  - REST: 8332    │         ┌────────────────────────┐   │
│  │  - ZMQ: 28332-5  │◄────────│  3xplCore              │   │
│  └────────┬─────────┘         │  (Explorer)            │   │
│           │                   └────────────────────────┘   │
│           │                                                  │
│           │                   ┌────────────────────────┐   │
│           │                   │  mining-pools          │   │
│           ├───────────────────│  (Analysis)            │   │
│           │                   └────────────────────────┘   │
│           │                                                  │
│           │                   ┌────────────────────────┐   │
│           └──────────────────►│  LND                   │   │
│                               │  (Lightning)           │   │
│                               └───────────┬────────────┘   │
│                                           │                 │
│                                           │                 │
│                               ┌───────────▼────────────┐   │
│                               │  lndhub                │   │
│                               │  (Lightning Accounts)  │   │
│                               └────────────────────────┘   │
│                                                             │
│  ┌──────────────────┐                                      │
│  │  Redis           │ (Optional - Caching/Sessions)        │
│  │  Port: 6379      │◄─────────────────────────────────────│
│  └──────────────────┘                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Docker Compose Integration

Create a `docker-compose.yml` in a central location to orchestrate all services:

```yaml
version: '3.8'

services:
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis-data:/data

  lndhub:
    build: ./lndhub
    ports:
      - "3000:3000"
    environment:
      - LND_HOST=host.docker.internal:10009
      - LND_CERT_PATH=/lnd/tls.cert
      - LND_MACAROON_PATH=/lnd/admin.macaroon
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=${REDIS_PASSWORD}
    volumes:
      - ~/.lnd:/lnd:ro
    depends_on:
      - redis

  3xplcore:
    build: ./3xplCore
    ports:
      - "8080:8080"
    environment:
      - BITCOIN_RPC_HOST=host.docker.internal
      - BITCOIN_RPC_PORT=8332
      - BITCOIN_RPC_USER=${BITCOIN_RPC_USER}
      - BITCOIN_RPC_PASS=${BITCOIN_RPC_PASS}
    depends_on:
      - redis

  mining-pools:
    build: ./mining-pools
    environment:
      - BITCOIN_RPC_HOST=host.docker.internal
      - BITCOIN_RPC_PORT=8332
      - BITCOIN_RPC_USER=${BITCOIN_RPC_USER}
      - BITCOIN_RPC_PASS=${BITCOIN_RPC_PASS}

volumes:
  redis-data:
```

Create `.env` file in the same directory:

```env
BITCOIN_RPC_USER=your_rpc_username
BITCOIN_RPC_PASS=your_strong_password
REDIS_PASSWORD=your_redis_password
```

Start all services:

```bash
docker-compose up -d
```

## Environment Variables Management

### Using PowerShell (Windows)

Use the provided `contrib/setup-integration.ps1`:

```powershell
cd contrib
.\setup-integration.ps1
```

### Using Bash (Linux/macOS)

Create `~/.bashrc` or `~/.profile` entries:

```bash
# Bitcoin Core
export BITCOIN_RPC_USER="your_rpc_username"
export BITCOIN_RPC_PASSWORD="your_strong_password"
export BITCOIN_RPC_HOST="127.0.0.1"
export BITCOIN_RPC_PORT="8332"

# Redis
export REDIS_HOST="localhost"
export REDIS_PORT="6379"
export REDIS_PASSWORD="your_redis_password"

# LND
export LND_HOST="localhost:10009"
export LND_CERT_PATH="$HOME/.lnd/tls.cert"
export LND_MACAROON_PATH="$HOME/.lnd/data/chain/bitcoin/mainnet/admin.macaroon"
```

## Testing the Complete Setup

### 1. Test Bitcoin Core

```bash
cd contrib/mempool-space
python3 test-integration.py --user $BITCOIN_RPC_USER --password $BITCOIN_RPC_PASSWORD
```

### 2. Test LND

```bash
lncli getinfo
lncli walletbalance
```

### 3. Test lndhub

```bash
curl http://localhost:3000/ping
```

### 4. Test Redis

```bash
redis-cli -a $REDIS_PASSWORD ping
```

### 5. Test 3xplCore

Check their API endpoints (refer to their documentation).

### 6. Test mining-pools

Run their analysis scripts (refer to their documentation).

## Monitoring and Maintenance

### Health Check Script

Create `health-check.sh`:

```bash
#!/bin/bash

echo "=== System Health Check ==="
echo ""

# Bitcoin Core
echo "Bitcoin Core:"
bitcoin-cli getblockchaininfo > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Running"
    BLOCKS=$(bitcoin-cli getblockcount)
    echo "    Blocks: $BLOCKS"
else
    echo "  ✗ Not running"
fi
echo ""

# LND
echo "LND:"
lncli getinfo > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Running"
else
    echo "  ✗ Not running"
fi
echo ""

# Redis
echo "Redis:"
redis-cli -a $REDIS_PASSWORD ping > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Running"
else
    echo "  ✗ Not running"
fi
echo ""

# lndhub
echo "lndhub:"
curl -s http://localhost:3000/ping > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  ✓ Running"
else
    echo "  ✗ Not running"
fi
```

### Log Monitoring

```bash
# Bitcoin Core logs
tail -f ~/.bitcoin/debug.log

# LND logs
tail -f ~/.lnd/logs/bitcoin/mainnet/lnd.log

# Docker logs
docker-compose logs -f
```

## Troubleshooting

### Issue: Cannot Connect to Bitcoin Core

**Check:**
1. Bitcoin Core is running: `ps aux | grep bitcoind`
2. RPC credentials are correct
3. `server=1` is in bitcoin.conf
4. Firewall allows connections

**Solution:**
```bash
bitcoin-cli stop
bitcoind --daemon
# Wait for startup
bitcoin-cli getblockchaininfo
```

### Issue: LND Won't Connect to Bitcoin Core

**Check:**
1. Bitcoin Core ZMQ is enabled
2. RPC credentials in lnd.conf match bitcoin.conf
3. Bitcoin Core is fully synced

**Solution:**
```bash
# Restart LND
lncli stop
lnd &
lncli unlock
```

### Issue: Docker Services Can't Reach Host

**Solution:**
Use `host.docker.internal` instead of `localhost` in Docker configs.

**Linux Alternative:**
Add `--add-host=host.docker.internal:host-gateway` to docker run commands.

### Issue: Redis Connection Failed

**Check:**
1. Redis is running: `redis-cli ping`
2. Password is correct
3. Port is not blocked

**Solution:**
```bash
# Restart Redis
sudo systemctl restart redis
# Or with Docker
docker restart redis
```

## Security Best Practices

1. **Never Commit Credentials**: Use `.env` files and add them to `.gitignore`
2. **Use Strong Passwords**: Generate with `openssl rand -base64 32`
3. **Restrict Network Access**: 
   - Bitcoin Core: `rpcbind=127.0.0.1`
   - Use firewall rules
4. **Regular Updates**: Keep all software updated
5. **Backup Important Data**:
   - Bitcoin Core wallet
   - LND wallet and channel backup
   - Redis data

## Resource Requirements

### Minimum System Requirements

- **CPU**: 4+ cores
- **RAM**: 16GB+
- **Disk**: 1TB+ SSD (Bitcoin Core blockchain ~600GB and growing)
- **Network**: High-speed, unmetered connection

### Recommended System Requirements

- **CPU**: 8+ cores
- **RAM**: 32GB+
- **Disk**: 2TB+ NVMe SSD
- **Network**: Gigabit connection with static IP

## Useful Commands Reference

### Bitcoin Core
```bash
bitcoin-cli getblockchaininfo      # Chain status
bitcoin-cli getmempoolinfo         # Mempool stats
bitcoin-cli getpeerinfo            # Network peers
bitcoin-cli stop                   # Graceful shutdown
```

### LND
```bash
lncli getinfo                      # Node info
lncli walletbalance               # On-chain balance
lncli channelbalance              # Lightning balance
lncli listchannels                # Active channels
```

### Docker
```bash
docker-compose ps                  # Service status
docker-compose logs -f             # Follow logs
docker-compose restart <service>   # Restart service
docker-compose down               # Stop all services
```

### System
```bash
df -h                             # Disk usage
free -h                           # Memory usage
htop                              # Process monitor
```

## Additional Resources

- [Bitcoin Core Documentation](https://bitcoin.org/en/bitcoin-core/)
- [LND Documentation](https://docs.lightning.engineering/)
- [Docker Documentation](https://docs.docker.com/)
- [mempool.space Integration](./mempool-space-integration.md)
- [Compliance Guide](./mempool-space-compliance.md)
- [Setup Scripts](../contrib/setup-integration.ps1)

## Getting Help

- **Bitcoin Core**: https://bitcoin.stackexchange.com/
- **LND**: https://github.com/lightningnetwork/lnd/issues
- **Individual Repositories**: Check their GitHub Issues

## Contributing

If you find improvements or have suggestions for this integration guide:

1. Test your changes thoroughly
2. Document clearly
3. Submit pull requests with examples

## License

This documentation follows the same license as the Miago.AI repository.
