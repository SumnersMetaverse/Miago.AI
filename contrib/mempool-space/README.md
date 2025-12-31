# mempool.space Integration

This directory contains configuration examples and documentation for integrating Bitcoin Core with mempool.space.

## Contents

- **bitcoin.conf.example** - Example Bitcoin Core configuration file optimized for mempool.space integration
- **README.md** - This comprehensive integration guide

## Quick Start

### 1. Configure Bitcoin Core

Copy the relevant settings from `bitcoin.conf.example` to your Bitcoin Core configuration file:

**Linux/macOS:**
```bash
nano ~/.bitcoin/bitcoin.conf
```

**Windows:**
```
notepad %APPDATA%\Bitcoin\bitcoin.conf
```

Minimal required settings:
```conf
server=1
rest=1
txindex=1
rpcuser=mempool
rpcpassword=your_secure_password
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
```

### 2. Restart Bitcoin Core

If you enabled `txindex=1` for the first time, you need to reindex:

```bash
bitcoind -reindex
```

Otherwise, a normal restart is sufficient:

```bash
bitcoind
```

### 3. Verify RPC Access

Test that Bitcoin Core RPC is accessible:

```bash
curl --user mempool:your_secure_password \
  --data-binary '{"jsonrpc":"2.0","id":"test","method":"getmempoolinfo","params":[]}' \
  -H 'content-type: application/json' \
  http://127.0.0.1:8332/
```

### 4. Install and Configure mempool.space

Clone the mempool.space repository:

```bash
git clone https://github.com/mempool/mempool.git
cd mempool
```

Configure the backend to connect to your Bitcoin Core node:

```bash
cd backend
cp mempool-config.sample.json mempool-config.json
nano mempool-config.json
```

Update the configuration:

```json
{
  "CORE_RPC": {
    "HOST": "127.0.0.1",
    "PORT": 8332,
    "USERNAME": "mempool",
    "PASSWORD": "your_secure_password"
  },
  "MEMPOOL": {
    "NETWORK": "mainnet",
    "BACKEND": "none",
    "HTTP_PORT": 8999,
    "API_URL_PREFIX": "/api/v1/",
    "POLL_RATE_MS": 2000
  },
  "DATABASE": {
    "ENABLED": true,
    "HOST": "127.0.0.1",
    "PORT": 3306,
    "USERNAME": "mempool",
    "PASSWORD": "mempool",
    "DATABASE": "mempool"
  }
}
```

### 5. Start mempool.space

Using Docker (recommended):

```bash
cd mempool/docker
docker-compose up -d
```

Or manually:

```bash
# Install dependencies
cd mempool/backend
npm install
npm run build

# Start backend
npm run start

# In another terminal, start frontend
cd mempool/frontend
npm install
npm run build
npm run serve
```

### 6. Access mempool.space

Open your browser and navigate to:

```
http://localhost:4200
```

## Advanced Configuration

### Enable ZMQ for Real-time Updates

Add to your bitcoin.conf:

```conf
zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333
zmqpubhashblock=tcp://127.0.0.1:28334
```

Then update mempool.space backend config:

```json
{
  "CORE_RPC": {
    "HOST": "127.0.0.1",
    "PORT": 8332,
    "USERNAME": "mempool",
    "PASSWORD": "your_secure_password"
  },
  "CORE_RPC_ZMQ": {
    "HOST": "127.0.0.1",
    "PORT": 28332
  }
}
```

### Performance Tuning

For better performance, increase these Bitcoin Core settings:

```conf
dbcache=4096           # More cache for better performance
rpcthreads=16         # More threads for handling RPC requests
maxmempool=500        # Larger mempool if you have RAM available
```

### Running on Different Networks

**Testnet:**
```conf
testnet=1
```

**Signet:**
```conf
signet=1
```

**Regtest (for development):**
```conf
regtest=1
```

Update mempool.space config accordingly:
```json
{
  "MEMPOOL": {
    "NETWORK": "testnet"  // or "signet" or "regtest"
  }
}
```

## Troubleshooting

### mempool.space shows no data

1. Check Bitcoin Core is running:
   ```bash
   bitcoin-cli getblockchaininfo
   ```

2. Verify RPC access:
   ```bash
   curl --user mempool:password \
     --data-binary '{"method":"getmempoolinfo"}' \
     http://127.0.0.1:8332/
   ```

3. Check mempool.space backend logs:
   ```bash
   cd mempool/backend
   npm run start  # Check console output
   ```

### Transaction lookups not working

Ensure `txindex=1` is enabled and Bitcoin Core has been reindexed:

```bash
bitcoin-cli getindexinfo
```

Should show:
```json
{
  "txindex": {
    "synced": true,
    "best_block_height": 850000
  }
}
```

### High CPU usage

Reduce polling frequency in mempool.space config:

```json
{
  "MEMPOOL": {
    "POLL_RATE_MS": 5000  // Increase from 2000 to 5000ms
  }
}
```

Or enable ZMQ to eliminate polling entirely.

### Connection refused errors

Check firewall settings:

```bash
# Linux - ONLY if mempool.space runs on a different machine
# WARNING: Do NOT allow external access if running on localhost
# This opens your RPC port to the network - only do this if needed
# sudo ufw allow 8332/tcp

# Check if port is listening
netstat -an | grep 8332
```

Ensure `rpcbind` and `rpcallowip` are set correctly in bitcoin.conf.

## Security Best Practices

1. **Use strong RPC credentials:**
   ```bash
   # Generate secure rpcauth
   python3 share/rpcauth/rpcauth.py mempool
   ```

2. **Restrict RPC access:**
   ```conf
   rpcallowip=127.0.0.1  # Localhost only
   rpcbind=127.0.0.1     # Bind to localhost only
   ```

3. **Use firewall rules:**
   ```bash
   # Only allow localhost connections to RPC port
   sudo ufw deny 8332/tcp
   ```

4. **Disable unused RPC methods:**
   ```conf
   rpcwhitelist=mempool:getblockchaininfo,getmempoolinfo,getrawmempool
   ```

5. **Run Bitcoin Core and mempool.space as non-root users**

## Resources

- [Bitcoin Core Documentation](https://bitcoin.org/en/bitcoin-core/)
- [mempool.space GitHub](https://github.com/mempool/mempool)
- [Bitcoin Core RPC Documentation](https://developer.bitcoin.org/reference/rpc/)
- [Bitcoin Core REST Documentation](https://github.com/bitcoin/bitcoin/blob/master/doc/REST-interface.md)

## Support

For Bitcoin Core issues:
- GitHub Issues: https://github.com/bitcoin/bitcoin/issues
- Bitcoin Stack Exchange: https://bitcoin.stackexchange.com/

For mempool.space issues:
- GitHub Issues: https://github.com/mempool/mempool/issues
- Discord: https://discord.gg/mempool

## Contributing

Contributions to improve this integration guide are welcome! Please submit pull requests to the Bitcoin Core repository.

## License

This documentation is released under the MIT License, consistent with Bitcoin Core.
