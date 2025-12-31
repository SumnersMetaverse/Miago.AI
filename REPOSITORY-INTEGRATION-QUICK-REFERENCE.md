# Quick Reference: Connecting Your SumnersMetaverse Repositories

> **IMPORTANT:** This is a reference guide. Use YOUR existing credentials from Tenderly, Redis repository, and Bitcoin Core. See `CREDENTIALS-MANAGEMENT-TEMPLATE.md` for details on secure credential storage.

## Your Repository Ecosystem

| Repository | Purpose | Connects to Bitcoin Core? | Status |
|------------|---------|----------------------------|--------|
| **bitcoin** (This repo) | Bitcoin Core node | N/A (this is the foundation) | ✅ Ready |
| **3xplCore** | Blockchain explorer engine | ✅ Yes - via RPC | ⚠️ Needs setup |
| **lndhub** | Lightning Network accounts | ✅ Yes - via LND + RPC | ⚠️ Needs LND + setup |
| **mining-pools** | Mining pool ID data | ✅ Yes - read-only | ⚠️ Can integrate |
| **mempool** | mempool.space explorer | ✅ Yes - via RPC/REST | ⚠️ Can integrate |

## Execution Order

### 1️⃣ Bitcoin Core (Foundation) - ALREADY RUNNING
```bash
# Verify it's running
bitcoin-cli getblockchaininfo

# Test RPC access
python3 contrib/mempool-space/test-integration.py --user YOUR_RPC_USER --password YOUR_RPC_PASSWORD
```

**Configuration:** `~/.bitcoin/bitcoin.conf`
**Documentation:** `contrib/mempool-space/README.md`

---

### 2️⃣ mempool.space (Optional but Recommended)

**Purpose:** Blockchain explorer and mempool visualizer

**Quick Setup:**
```bash
# Clone
git clone https://github.com/mempool/mempool.git
cd mempool

# Configure backend
cd backend
cp mempool-config.sample.json mempool-config.json
# Edit mempool-config.json with your Bitcoin Core credentials

# Install and run
npm install
npm run build
npm start
```

**Configuration File:** `mempool-config.json` in backend directory
**Documentation:** `contrib/mempool-space/README.md`
**Compliance:** `doc/mempool-space-compliance.md`

---

### 3️⃣ 3xplCore (Blockchain Explorer)

**Purpose:** Multi-chain blockchain explorer core

**Quick Setup:**
```bash
# Clone your 3xplCore repository
cd ~/projects
git clone https://github.com/SumnersMetaverse/3xplCore.git
cd 3xplCore

# Set environment variables (use YOUR credentials)
export BITCOIN_RPC_HOST=127.0.0.1
export BITCOIN_RPC_PORT=8332
export BITCOIN_RPC_USER=YOUR_RPC_USER
export BITCOIN_RPC_PASSWORD=YOUR_RPC_PASSWORD

# Follow 3xplCore setup instructions from its README
```

**Needs Access To:**
- Bitcoin Core RPC (getblock, getrawtransaction, getblockchaininfo)
- Optional: Bitcoin Core REST API

**Documentation:** `doc/repository-integration-guide.md`

---

### 4️⃣ Lightning Network Daemon (LND) - Required for lndhub

**Purpose:** Lightning Network node running on top of Bitcoin Core

**Quick Setup:**
```bash
# Install LND
# See: https://github.com/lightningnetwork/lnd/blob/master/docs/INSTALL.md

# Configure lnd.conf
nano ~/.lnd/lnd.conf
```

**Minimal lnd.conf:**
```conf
[Application Options]
debuglevel=info
maxpendingchannels=10

[Bitcoin]
bitcoin.active=true
bitcoin.mainnet=true
bitcoin.node=bitcoind

[Bitcoind]
bitcoind.rpchost=127.0.0.1:8332
bitcoind.rpcuser=YOUR_RPC_USER
bitcoind.rpcpass=YOUR_RPC_PASSWORD
bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332
bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333
```

**Start LND:**
```bash
lnd
```

**Documentation:** `doc/repository-integration-guide.md` (Lightning Network section)

---

### 5️⃣ lndhub (Lightning Accounts)

**Purpose:** Lightning Network account abstraction for users

**Quick Setup:**
```bash
# Clone your lndhub repository
cd ~/projects
git clone https://github.com/SumnersMetaverse/lndhub.git
cd lndhub

# Configure with LND macaroon and credentials
export LND_HOST=127.0.0.1:10009
export LND_TLS_CERT_PATH=~/.lnd/tls.cert
export LND_MACAROON_PATH=~/.lnd/data/chain/bitcoin/mainnet/admin.macaroon

# Follow lndhub setup instructions
npm install
npm start
```

**Needs:**
- Running LND instance
- LND admin.macaroon for authentication
- LND TLS certificate

**Documentation:** `doc/repository-integration-guide.md` (lndhub section)

---

### 6️⃣ mining-pools (Mining Pool Data)

**Purpose:** Bitcoin mining pool identification

**Quick Setup:**
```bash
# Clone your mining-pools repository
cd ~/projects
git clone https://github.com/SumnersMetaverse/mining-pools.git
cd mining-pools

# Configure Bitcoin Core connection
export BITCOIN_RPC_HOST=127.0.0.1
export BITCOIN_RPC_PORT=8332
export BITCOIN_RPC_USER=YOUR_RPC_USER
export BITCOIN_RPC_PASSWORD=YOUR_RPC_PASSWORD

# Follow repository instructions
```

**Needs Access To:**
- Bitcoin Core RPC (read-only)
- Block data for coinbase analysis

**Documentation:** `doc/repository-integration-guide.md` (mining-pools section)

---

## Environment Variables Quick Reference

Create a `.env` file in each project (add to `.gitignore`):

```bash
# Bitcoin Core
BITCOIN_RPC_HOST=127.0.0.1
BITCOIN_RPC_PORT=8332
BITCOIN_RPC_USER=your_username
BITCOIN_RPC_PASSWORD=your_password

# Lightning Network (if using LND)
LND_HOST=127.0.0.1:10009
LND_TLS_CERT_PATH=/path/to/.lnd/tls.cert
LND_MACAROON_PATH=/path/to/admin.macaroon

# Redis (if needed)
REDIS_HOST=your_redis_host
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# Tenderly (if using)
TENDERLY_API_KEY=your_api_key
TENDERLY_PROJECT_ID=your_project_id
```

**NEVER commit `.env` files to Git!**

---

## Common Commands Cheat Sheet

### Bitcoin Core
```bash
# Check status
bitcoin-cli getblockchaininfo

# Check mempool
bitcoin-cli getmempoolinfo

# Get block
bitcoin-cli getblock <block_hash>

# Get transaction
bitcoin-cli getrawtransaction <txid> 1
```

### Lightning Network (LND)
```bash
# Check LND status
lncli getinfo

# List channels
lncli listchannels

# Get wallet balance
lncli walletbalance
```

### Testing Integration
```bash
# Test Bitcoin Core RPC
python3 contrib/mempool-space/test-integration.py --user USER --password PASS

# Test with curl
curl --user USER:PASS \
  --data-binary '{"jsonrpc":"2.0","id":"test","method":"getblockchaininfo","params":[]}' \
  -H 'content-type: application/json' \
  http://127.0.0.1:8332/
```

---

## Troubleshooting Quick Links

| Issue | Solution Guide |
|-------|---------------|
| Bitcoin Core not responding | `contrib/mempool-space/README.md` - Troubleshooting section |
| RPC authentication failing | `doc/mempool-space-integration.md` - Security section |
| LND connection issues | `doc/repository-integration-guide.md` - Lightning Network section |
| Rate limiting errors | `doc/mempool-space-compliance.md` |
| General integration issues | `doc/repository-integration-guide.md` - Troubleshooting section |

---

## Docker Compose (All Services)

For running everything together, see `doc/repository-integration-guide.md` for the complete Docker Compose configuration.

**Quick start:**
```bash
# Create docker-compose.yml (see doc/repository-integration-guide.md)
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

---

## Security Checklist

Before running in production:

- [ ] Use strong RPC credentials (not default values)
- [ ] Store credentials securely (see `CREDENTIALS-MANAGEMENT-TEMPLATE.md`)
- [ ] Enable firewall rules (only localhost access for RPC)
- [ ] Use rpcauth instead of rpcuser/rpcpassword
- [ ] Backup your wallet.dat and LND channel.backup files
- [ ] Test credential rotation procedures
- [ ] Set up monitoring and alerts
- [ ] Document your credential storage locations
- [ ] Review `.gitignore` to ensure sensitive files won't be committed
- [ ] Use separate credentials for each environment (dev/staging/prod)

---

## Next Steps

1. **Start with Bitcoin Core** - Verify it's running properly
2. **Test RPC access** - Use the integration test script
3. **Choose your first integration:**
   - For blockchain exploration: Set up **mempool.space** or **3xplCore**
   - For Lightning Network: Set up **LND** then **lndhub**
   - For mining analysis: Set up **mining-pools**
4. **Review security** - Follow `CREDENTIALS-MANAGEMENT-TEMPLATE.md`
5. **Set up monitoring** - See `doc/repository-integration-guide.md`

---

## Documentation Index

| Document | Purpose |
|----------|---------|
| `README.md` | Project overview |
| `MEMPOOL-SPACE-CROSS-REFERENCE.md` | mempool.space integration overview |
| `CREDENTIALS-MANAGEMENT-TEMPLATE.md` | Secure credential storage guide |
| `contrib/mempool-space/README.md` | Quick start for mempool.space |
| `doc/mempool-space-integration.md` | Technical integration details |
| `doc/mempool-space-compliance.md` | API usage and rate limits |
| `doc/repository-integration-guide.md` | Complete multi-repo setup |

---

## Support

- Bitcoin Core Issues: https://github.com/bitcoin/bitcoin/issues
- LND Issues: https://github.com/lightningnetwork/lnd/issues
- mempool.space Issues: https://github.com/mempool/mempool/issues

---

**Last Updated:** 2025-12-31
