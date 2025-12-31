# Important: Using Your Existing Credentials

## What This Documentation Is

The documentation in this repository (`doc/mempool-space-integration.md`, `doc/repository-integration-guide.md`, etc.) is **reference material** that shows you:

- HOW to connect your repositories together
- WHERE to place configuration values
- WHAT order to execute things in
- HOW to troubleshoot issues

## What This Documentation Is NOT

This documentation does NOT:
- ❌ Replace your existing Docker files
- ❌ Replace your existing configuration files
- ❌ Create new RPC credentials you need to use
- ❌ Contain your actual server information

## Using Your Existing Setup

### Your Existing Files to Use

You already have configuration files in your repositories:

1. **lndhub** - Already has:
   - `Dockerfile` - Use this!
   - `config.js` - Configure with YOUR credentials
   - Docker Compose files (if any)

2. **3xplCore** - Already has:
   - `.env.example` - Copy to `.env` and add YOUR credentials
   - Setup scripts

3. **mining-pools** - Already has:
   - Data files to reference

### Your Existing Credentials to Use

#### From Tenderly.co
You mentioned you have RPC endpoints in Tenderly. Use those:
- Your Tenderly RPC URLs
- Your Tenderly API keys
- Your Tenderly project settings

#### From Your Redis Repository
You mentioned your private server info is there. Use that:
- Your Redis host address
- Your Redis port
- Your Redis password (if set)
- Your server IPs and configurations

#### From Bitcoin Core
Your Bitcoin Core RPC credentials (from `~/.bitcoin/bitcoin.conf`):
- Your actual `rpcuser` value
- Your actual `rpcpassword` value
- Your actual `rpcport` (if custom)

## How to Use This Documentation

### Step 1: Find Your Actual Credentials

**For Tenderly RPC:**
1. Log into https://tenderly.co
2. Go to your project/dashboard
3. Navigate to Node RPC section
4. Find your RPC URL (looks like: `https://mainnet.gateway.tenderly.co/...`)
5. Copy your API key

**For Redis:**
1. Look in your Redis repository
2. Find configuration file or documentation
3. Note down:
   - Host IP/domain
   - Port number
   - Password (if configured)

**For Bitcoin Core:**
1. Open `~/.bitcoin/bitcoin.conf`
2. Find these lines:
   ```
   rpcuser=your_actual_username
   rpcpassword=your_actual_password
   ```
3. Write these down (store securely!)

### Step 2: Update Your Repository Configuration Files

**For lndhub:**
```bash
cd /path/to/your/lndhub
nano config.js  # or your preferred editor
```

Look for sections that need Bitcoin Core RPC connection:
```javascript
// Replace placeholders with YOUR actual values
redis: {
  host: 'YOUR_REDIS_HOST',      // From your Redis repo
  port: 6379,                    // From your Redis repo
  password: 'YOUR_REDIS_PASS'    // From your Redis repo
}

bitcoind: {
  rpcuser: 'YOUR_BITCOIN_RPC_USER',      // From bitcoin.conf
  rpcpassword: 'YOUR_BITCOIN_RPC_PASS',  // From bitcoin.conf
  rpchost: '127.0.0.1',
  rpcport: 8332
}
```

**For 3xplCore:**
```bash
cd /path/to/your/3xplCore
cp .env.example .env
nano .env
```

Update with YOUR values:
```bash
BITCOIN_RPC_HOST=127.0.0.1
BITCOIN_RPC_PORT=8332
BITCOIN_RPC_USER=your_actual_username    # From bitcoin.conf
BITCOIN_RPC_PASSWORD=your_actual_password # From bitcoin.conf

REDIS_HOST=your_redis_host               # From Redis repo
REDIS_PORT=6379                          # From Redis repo
REDIS_PASSWORD=your_redis_password       # From Redis repo

TENDERLY_API_KEY=your_tenderly_key       # From tenderly.co
```

### Step 3: Use Documentation as Reference

When the documentation says things like:
```bash
# Example from documentation
BITCOIN_RPC_USER=mempool
BITCOIN_RPC_PASSWORD=your_secure_password
```

**You should instead use YOUR actual values:**
```bash
# Your actual configuration
BITCOIN_RPC_USER=john_actual_username      # Whatever is in YOUR bitcoin.conf
BITCOIN_RPC_PASSWORD=john_actual_password  # Whatever is in YOUR bitcoin.conf
```

### Step 4: Test Connection

Use the test scripts with YOUR credentials:

```bash
# Use YOUR actual credentials here
python3 contrib/mempool-space/test-integration.py \
  --user your_actual_rpc_username \
  --password your_actual_rpc_password
```

## Common Misunderstandings

### ❌ Wrong: "I need to create new credentials"
**✅ Correct:** Use your existing credentials from bitcoin.conf, Tenderly, and Redis repo

### ❌ Wrong: "I should use the example values from the documentation"
**✅ Correct:** Replace example values with YOUR actual credentials

### ❌ Wrong: "The documentation contains my server info"
**✅ Correct:** The documentation shows WHERE to put your info, not WHAT info to use

### ❌ Wrong: "I need to reconfigure Bitcoin Core with new credentials"
**✅ Correct:** Use whatever credentials you already have configured

## Security Reminders

### DO:
✅ Use YOUR existing credentials
✅ Store credentials in password manager (see `CREDENTIALS-MANAGEMENT-TEMPLATE.md`)
✅ Keep credentials in `.env` files (already in `.gitignore`)
✅ Use your existing Docker files from your repos

### DON'T:
❌ Commit credentials to Git
❌ Share credentials in comments/issues
❌ Use example/placeholder values in production
❌ Create new credentials unless absolutely necessary

## Quick Credential Mapping

| What Documentation Says | What YOU Should Use |
|------------------------|---------------------|
| `rpcuser=mempool` | Your actual `rpcuser` from bitcoin.conf |
| `rpcpassword=your_secure_password` | Your actual `rpcpassword` from bitcoin.conf |
| `REDIS_HOST=YOUR_REDIS_HOST` | Your actual Redis host from your Redis repo |
| `TENDERLY_API_KEY=YOUR_KEY` | Your actual Tenderly API key from tenderly.co |

## Where Your Actual Information Is

1. **Bitcoin Core RPC Credentials:**
   - File: `~/.bitcoin/bitcoin.conf`
   - Lines: `rpcuser=...` and `rpcpassword=...`

2. **Tenderly Credentials:**
   - Website: https://tenderly.co
   - Location: Project Dashboard → Node RPC section

3. **Redis Information:**
   - Location: Your Redis repository
   - Check: README, config files, or documentation in that repo

4. **Your lndhub Docker Files:**
   - Location: Your lndhub repository
   - Files: `Dockerfile`, `docker-compose.yml`, `config.js`

5. **Your 3xplCore Configuration:**
   - Location: Your 3xplCore repository
   - Files: `.env.example`, setup scripts

## Getting Help

If you're confused about:

1. **"Where do I find my Bitcoin Core credentials?"**
   - Open terminal
   - Run: `cat ~/.bitcoin/bitcoin.conf`
   - Look for `rpcuser` and `rpcpassword` lines

2. **"Where is my Redis information?"**
   - Check your Redis repository
   - Look for README.md or configuration files
   - Check any setup scripts you ran

3. **"What are my Tenderly credentials?"**
   - Log into https://tenderly.co
   - Navigate to your project
   - Go to Node RPC section
   - Your RPC URL and API key are there

4. **"How do I test if my credentials work?"**
   ```bash
   # Test Bitcoin Core
   bitcoin-cli -rpcuser=YOUR_USER -rpcpassword=YOUR_PASS getblockchaininfo
   
   # Test with the integration script
   python3 contrib/mempool-space/test-integration.py \
     --user YOUR_USER \
     --password YOUR_PASS
   ```

## Example Workflow

Here's a complete example of using YOUR credentials:

### Step 1: Get Bitcoin Core credentials
```bash
# Check your bitcoin.conf
cat ~/.bitcoin/bitcoin.conf | grep rpc
```

Output might show:
```
rpcuser=alice_btc_user
rpcpassword=SecurePass123!
rpcport=8332
```

### Step 2: Use those in lndhub config.js
```javascript
// In your lndhub/config.js
module.exports = {
  bitcoind: {
    rpcuser: 'alice_btc_user',        // ← YOUR actual username
    rpcpassword: 'SecurePass123!',    // ← YOUR actual password
    rpchost: '127.0.0.1',
    rpcport: 8332
  }
}
```

### Step 3: Use those in 3xplCore .env
```bash
# In your 3xplCore/.env
BITCOIN_RPC_USER=alice_btc_user      # ← YOUR actual username
BITCOIN_RPC_PASSWORD=SecurePass123!  # ← YOUR actual password
BITCOIN_RPC_HOST=127.0.0.1
BITCOIN_RPC_PORT=8332
```

### Step 4: Test with YOUR credentials
```bash
python3 contrib/mempool-space/test-integration.py \
  --user alice_btc_user \
  --password 'SecurePass123!'
```

## Summary

**The key point:** This documentation is a HOW-TO guide, not a WHAT-TO-USE guide.

- **Documentation shows:** How to structure configuration files
- **You provide:** Your actual credentials from existing systems
- **Your existing files:** Use your Dockerfiles and configs from your repos
- **Security:** Store credentials properly (see `CREDENTIALS-MANAGEMENT-TEMPLATE.md`)

When in doubt, remember: **Use YOUR existing credentials, not the examples!**

## Related Files

- `CREDENTIALS-MANAGEMENT-TEMPLATE.md` - How to securely store credentials
- `doc/repository-integration-guide.md` - How to connect repositories (technical guide)
- `REPOSITORY-INTEGRATION-QUICK-REFERENCE.md` - Quick commands reference
- `contrib/mempool-space/test-integration.py` - Test script (use with YOUR credentials)
