# Bitcoin Core and mempool.space Integration Guide

## Overview

This document provides a comprehensive cross-reference between Bitcoin Core and the mempool.space project, explaining how they integrate and what developers need to know when working with both repositories.

## What is mempool.space?

mempool.space (https://github.com/mempool/mempool) is an open-source Bitcoin blockchain explorer and mempool visualizer. It provides:

- Real-time mempool visualization
- Transaction tracking and analysis
- Block explorer functionality
- Fee estimation tools
- Network statistics and monitoring

## How mempool.space Integrates with Bitcoin Core

mempool.space acts as a frontend/middleware layer that connects to Bitcoin Core to:

1. **Fetch mempool data** via RPC and REST APIs
2. **Query blockchain information** for block and transaction details
3. **Monitor network activity** through transaction propagation
4. **Provide fee estimates** based on mempool state

## Bitcoin Core APIs Used by mempool.space

### JSON-RPC API Endpoints

mempool.space primarily uses the following RPC methods:

#### Mempool-Related RPCs
- `getrawmempool` - Returns all transaction IDs in the mempool
- `getmempoolentry` - Returns mempool data for a specific transaction
- `getmempoolinfo` - Returns mempool statistics
- `getmempoolancestors` - Returns ancestor transactions
- `getmempooldescendants` - Returns descendant transactions

#### Block and Transaction RPCs
- `getblock` - Fetches block data
- `getblockheader` - Fetches block header information
- `getblockcount` - Returns the current block height
- `getblockhash` - Returns block hash for a given height
- `getrawtransaction` - Fetches transaction data
- `gettxout` - Returns details about an unspent transaction output

#### Network and Chain Info RPCs
- `getblockchaininfo` - Returns blockchain state information
- `getnetworkinfo` - Returns network information
- `getpeerinfo` - Returns peer connection data
- `estimatesmartfee` - Provides fee estimates

#### Mining and Difficulty RPCs
- `getdifficulty` - Returns current mining difficulty
- `getmininginfo` - Returns mining-related information
- `getblockstats` - Returns block statistics

### REST API Endpoints

mempool.space also uses Bitcoin Core's REST API for efficient data queries:

- `/rest/block/<hash>.<format>` - Block data by hash
- `/rest/tx/<hash>.<format>` - Transaction data by hash
- `/rest/chaininfo.<format>` - Blockchain information
- `/rest/mempool/info.<format>` - Mempool information
- `/rest/mempool/contents.<format>` - All mempool transactions

Where `<format>` can be:
- `json` - JSON format
- `bin` - Binary format
- `hex` - Hexadecimal format

## Required Bitcoin Core Configuration

For mempool.space to function properly, Bitcoin Core must be configured with specific settings:

### Minimum Required Settings

```conf
# Enable RPC server
server=1

# Enable REST API
rest=1

# Enable transaction index (required for full functionality)
txindex=1
```

### Recommended Settings

```conf
# RPC Authentication
rpcuser=mempool
rpcpassword=<strong-password>

# Bind RPC to localhost only (security)
rpcbind=127.0.0.1
rpcallowip=127.0.0.1

# Increase mempool size for better analysis (optional)
maxmempool=500

# Improve performance
dbcache=4096
```

See [`contrib/mempool-space/bitcoin.conf.example`](../contrib/mempool-space/bitcoin.conf.example) for complete configuration examples.

## Data Flow Architecture

### 1. Real-Time Mempool Updates

```
Bitcoin Core → mempool.space Backend → Database → Frontend
```

**Process:**
1. mempool.space backend polls `getrawmempool` periodically (default: 2 seconds)
2. Compares with previous mempool state to detect new/removed transactions
3. Fetches details for new transactions using `getmempoolentry`
4. Stores processed data in database (MySQL/MariaDB)
5. Frontend queries database and displays results

### 2. Block Data Retrieval

```
Bitcoin Core → ZMQ (optional) → mempool.space Backend → Database
```

**Process:**
1. When new block arrives, Bitcoin Core notifies via ZMQ (if configured)
2. OR backend detects via polling `getblockcount`
3. Backend fetches block using `getblock`
4. Processes transactions and updates database
5. Frontend displays new block information

### 3. Historical Data Queries

```
Frontend Request → Backend API → Bitcoin Core RPC → Response
```

**Process:**
1. User requests historical transaction/block via frontend
2. Backend checks cache/database first
3. If not cached, queries Bitcoin Core via RPC
4. Returns formatted data to frontend

## ZMQ Integration (Optional but Recommended)

### What is ZMQ?

ZeroMQ (ZMQ) provides real-time notifications from Bitcoin Core, eliminating the need for constant polling.

### ZMQ Configuration

Add to `bitcoin.conf`:

```conf
# ZMQ notifications
zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333
zmqpubhashtx=tcp://127.0.0.1:28334
zmqpubhashblock=tcp://127.0.0.1:28335
```

### Benefits of ZMQ

- **Lower latency**: Immediate notifications instead of polling
- **Reduced load**: No repeated RPC calls
- **Real-time updates**: Block and transaction announcements as they happen

## mempool.space Backend Configuration

### Connecting to Bitcoin Core

Edit `mempool-config.json` in the mempool.space backend:

```json
{
  "CORE_RPC": {
    "HOST": "127.0.0.1",
    "PORT": 8332,
    "USERNAME": "mempool",
    "PASSWORD": "your-rpc-password"
  },
  "CORE_RPC_TIMEOUT": 60000
}
```

### ZMQ Configuration

If using ZMQ:

```json
{
  "CORE_RPC_ZMQ": {
    "HOST": "127.0.0.1",
    "PORT": 28332
  }
}
```

### Network-Specific Ports

Different networks use different ports:

| Network | RPC Port | ZMQ Block Port | ZMQ TX Port |
|---------|----------|----------------|-------------|
| Mainnet | 8332     | 28332          | 28333       |
| Testnet | 18332    | 38332          | 38333       |
| Signet  | 38332    | 48332          | 48333       |
| Regtest | 18443    | 38443          | 38444       |

## Performance Considerations

### Bitcoin Core Side

1. **Transaction Index (`txindex=1`)**
   - Enables lookup of any transaction
   - Requires full blockchain reindex (can take days)
   - Uses additional disk space (~100GB as of 2024)

2. **Database Cache (`dbcache`)**
   - Default: 450 MB
   - Recommended: 4096 MB or more
   - Improves query performance

3. **RPC Thread Count (`rpcthreads`)**
   - Default: 4
   - Increase for high-traffic setups: 16-32
   - Allows parallel RPC requests

### mempool.space Backend

1. **Polling Frequency**
   - Default: 2 seconds (`POLL_RATE_MS=2000`)
   - Lower = more real-time but higher load
   - Higher = less load but slower updates

2. **Database Optimization**
   - Use indexes on frequently queried columns
   - Regular vacuum/optimize operations
   - Consider read replicas for high traffic

3. **Caching Strategy**
   - Cache immutable data (confirmed blocks/transactions)
   - Short TTL for mempool data (volatile)
   - Use Redis for session and API caching

## Development Setup

### 1. Setup Bitcoin Core

```bash
# Install Bitcoin Core
wget https://bitcoincore.org/bin/bitcoin-core-<version>/bitcoin-<version>-x86_64-linux-gnu.tar.gz
tar xzf bitcoin-<version>-x86_64-linux-gnu.tar.gz
sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-<version>/bin/*

# Configure
mkdir -p ~/.bitcoin
cp contrib/mempool-space/bitcoin.conf.example ~/.bitcoin/bitcoin.conf
# Edit with your credentials

# Start Bitcoin Core
bitcoind -daemon

# Wait for sync (can take days)
bitcoin-cli getblockchaininfo
```

### 2. Setup mempool.space

```bash
# Clone repository
git clone https://github.com/mempool/mempool.git
cd mempool

# Setup database
mysql -u root -p
CREATE DATABASE mempool;
CREATE USER 'mempool'@'localhost' IDENTIFIED BY 'mempool';
GRANT ALL PRIVILEGES ON mempool.* TO 'mempool'@'localhost';

# Configure backend
cd backend
npm install
cp mempool-config.sample.json mempool-config.json
# Edit with your Bitcoin Core credentials

# Initialize database
npm run migrate

# Start backend
npm run start

# In another terminal, start frontend
cd ../frontend
npm install
npm run build
npm run serve
```

### 3. Verify Integration

Use the test script to verify everything is working:

```bash
cd contrib/mempool-space
python3 test-integration.py --user mempool --password your-password
```

## API Usage Patterns

### Efficient Querying

**Good Practice:**
```python
# Batch requests where possible
def get_multiple_transactions(txids):
    # Use getmempoolentry for mempool txs
    mempool_txs = []
    for txid in txids:
        try:
            tx = rpc.getmempoolentry(txid)
            mempool_txs.append(tx)
        except:
            # Not in mempool, use getrawtransaction
            tx = rpc.getrawtransaction(txid, True)
            mempool_txs.append(tx)
    return mempool_txs
```

**Bad Practice:**
```python
# Avoid repeated full mempool scans
def find_transaction(txid):
    # DON'T DO THIS
    all_txs = rpc.getrawmempool(True)  # Returns entire mempool
    return all_txs.get(txid)
```

### Caching Strategy

```python
from functools import lru_cache
import time

@lru_cache(maxsize=1000)
def get_cached_block(block_hash):
    """Cache immutable block data"""
    return rpc.getblock(block_hash, 2)

def get_mempool_info():
    """Don't cache volatile mempool data"""
    return rpc.getmempoolinfo()
```

## Troubleshooting Common Integration Issues

### Issue: Connection Refused

**Symptoms:**
```
Error: Connection refused to 127.0.0.1:8332
```

**Solutions:**
1. Check Bitcoin Core is running: `bitcoin-cli getblockchaininfo`
2. Verify `server=1` in bitcoin.conf
3. Check firewall settings
4. Ensure correct port for network (mainnet=8332, testnet=18332)

### Issue: Authentication Failed

**Symptoms:**
```
Error: 401 Unauthorized
```

**Solutions:**
1. Verify RPC credentials match bitcoin.conf
2. Check rpcuser and rpcpassword are set correctly
3. For rpcauth, ensure proper format
4. Restart Bitcoin Core after config changes

### Issue: Transaction Index Required

**Symptoms:**
```
Error: No such mempool or blockchain transaction
```

**Solutions:**
1. Enable `txindex=1` in bitcoin.conf
2. Restart with `-reindex` flag (takes hours/days)
3. Wait for full reindex completion
4. Verify with: `bitcoin-cli getindexinfo`

### Issue: High Memory Usage

**Symptoms:**
- mempool.space backend using excessive RAM
- Bitcoin Core OOM errors

**Solutions:**
1. Increase Bitcoin Core `dbcache` setting
2. Reduce mempool.space polling frequency
3. Implement request rate limiting
4. Use connection pooling
5. Monitor with `bitcoin-cli getmemoryinfo`

### Issue: Slow Query Performance

**Symptoms:**
- Slow API responses
- Backend timeouts

**Solutions:**
1. Enable txindex for faster transaction lookups
2. Increase RPC timeout values
3. Use REST API instead of RPC for bulk data
4. Implement database indexing
5. Use ZMQ for real-time updates (avoid polling)

## Security Best Practices

### Bitcoin Core Security

1. **Restrict RPC Access**
   ```conf
   rpcbind=127.0.0.1  # Localhost only
   rpcallowip=127.0.0.1  # Single IP only
   ```

2. **Use Strong Authentication**
   ```bash
   # Generate rpcauth
   python3 share/rpcauth/rpcauth.py mempool
   # Add output to bitcoin.conf
   ```

3. **Firewall Configuration**
   ```bash
   # Block external RPC access
   sudo ufw deny 8332/tcp
   ```

### mempool.space Security

1. **Environment Variables**
   - Store credentials in environment variables
   - Never commit credentials to git
   - Use `.env` files (add to `.gitignore`)

2. **Network Security**
   - Run backend on private network
   - Use reverse proxy (nginx) for frontend
   - Enable HTTPS/TLS

3. **Database Security**
   - Use separate database user with minimal privileges
   - Enable database authentication
   - Regular backups

## Monitoring and Maintenance

### Key Metrics to Monitor

1. **Bitcoin Core Metrics**
   - Mempool size: `bitcoin-cli getmempoolinfo`
   - Connection count: `bitcoin-cli getnetworkinfo`
   - Sync progress: `bitcoin-cli getblockchaininfo`
   - Disk usage: `du -sh ~/.bitcoin`

2. **mempool.space Metrics**
   - API response times
   - Database query performance
   - Backend memory usage
   - Frontend load times

### Regular Maintenance

1. **Bitcoin Core**
   - Monitor disk space (blockchain grows ~50GB/year)
   - Update to latest version regularly
   - Check logs for errors: `tail -f ~/.bitcoin/debug.log`

2. **mempool.space**
   - Update dependencies: `npm update`
   - Optimize database: `OPTIMIZE TABLE` in MySQL
   - Clear old cached data
   - Monitor error logs

## Testing Your Integration

### Manual Testing

```bash
# Test RPC connection
curl --user mempool:password \
  --data-binary '{"method":"getblockchaininfo"}' \
  http://127.0.0.1:8332/

# Test REST API
curl http://127.0.0.1:8332/rest/chaininfo.json

# Test mempool access
curl --user mempool:password \
  --data-binary '{"method":"getrawmempool"}' \
  http://127.0.0.1:8332/
```

### Automated Testing

Use our integration test script:

```bash
cd contrib/mempool-space
python3 test-integration.py --user mempool --password your-password --verbose
```

## Resources

### Documentation
- [Bitcoin Core RPC Documentation](https://developer.bitcoin.org/reference/rpc/)
- [Bitcoin Core REST Documentation](https://github.com/bitcoin/bitcoin/blob/master/doc/REST-interface.md)
- [mempool.space GitHub](https://github.com/mempool/mempool)
- [Setup Guide](../contrib/mempool-space/README.md)
- [Compliance Guide](./mempool-space-compliance.md)

### Tools
- [Integration Test Script](../contrib/mempool-space/test-integration.py)
- [Setup Automation (Windows)](../contrib/setup-integration.ps1)
- [Configuration Example](../contrib/mempool-space/bitcoin.conf.example)

### Support
- Bitcoin Core: https://bitcoin.stackexchange.com/
- mempool.space: https://github.com/mempool/mempool/issues

## Contributing

If you find issues with this integration guide or have improvements:

1. Test your changes thoroughly
2. Update relevant documentation
3. Submit a pull request with clear description

## Changelog

### Version 1.0.0 (2025-12-31)
- Initial integration guide
- Bitcoin Core API reference
- Architecture documentation
- Setup and troubleshooting guides
- Security best practices
