# mempool.space Integration

This directory contains configuration examples and documentation for integrating Bitcoin Core with mempool.space.

## Contents

- **bitcoin.conf.example** - Example Bitcoin Core configuration file optimized for mempool.space integration
- **test-integration.py** - Python script to test your Bitcoin Core configuration
- **README.md** - This comprehensive integration guide

## Testing Your Configuration

Before proceeding with the full mempool.space setup, you can verify that your Bitcoin Core node is properly configured using the included test script:

```bash
python3 test-integration.py --user <rpc_username> --password <rpc_password>
```

Example:
```bash
python3 test-integration.py --user mempool --password mypassword
```

The script will test:
- RPC connection and authentication
- REST API accessibility
- Transaction index status
- Mempool access
- Network information

For remote nodes:
```bash
python3 test-integration.py --user mempool --password mypassword --host 192.168.1.100 --port 8332 --verbose
```

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
bitcoind --reindex
```

Otherwise, a normal restart is sufficient:

```bash
# Run in background (daemon mode)
bitcoind --daemon

# Or if using systemd
# systemctl restart bitcoind
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
    "NETWORK": "testnet"
  }
}
```

_Note: Use "testnet", "signet", or "regtest" depending on your network choice._

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
# Check if port is listening
netstat -an | grep 8332
```

Ensure `rpcbind` and `rpcallowip` are set correctly in bitcoin.conf.

**Note:** For localhost-only setups, no firewall rules are typically needed since the RPC port only binds to 127.0.0.1. If you need to allow remote access (not recommended), configure `rpcbind` and `rpcallowip` carefully in bitcoin.conf and add appropriate firewall rules.

## Security Best Practices

1. **Use strong RPC credentials:**
   ```bash
   # Generate secure rpcauth using the script in your Bitcoin Core installation
   # The script is typically located at: share/rpcauth/rpcauth.py
   python3 /path/to/bitcoin/share/rpcauth/rpcauth.py mempool
   ```

2. **Restrict RPC access:**
   ```conf
   rpcallowip=127.0.0.1  # Localhost only
   rpcbind=127.0.0.1     # Bind to localhost only
   ```

3. **Use firewall rules (if needed):**
   ```bash
   # For localhost-only access, ensure RPC port is not exposed
   # The default configuration with rpcbind=127.0.0.1 keeps it secure
   
   # If you need to allow specific external hosts (advanced use case):
   # Replace placeholders with actual values:
   #   <trusted_ip> - IP address of the machine running mempool.space
   #   <server_ip> - IP address of your Bitcoin Core server
   # sudo ufw allow from <trusted_ip> to <server_ip> port 8332
   ```

4. **Disable unused RPC methods (optional):**
   ```conf
   # Example whitelist - adjust based on your needs
   # Common methods needed by mempool.space:
   rpcwhitelist=mempool:getblockchaininfo,getmempoolinfo,getrawmempool
   rpcwhitelist=mempool:getbestblockhash,getblock,getblockhash,getblockheader
   rpcwhitelist=mempool:getrawtransaction,sendrawtransaction
   rpcwhitelist=mempool:estimatesmartfee,getnetworkinfo
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
