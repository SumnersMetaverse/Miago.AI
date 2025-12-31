# Credentials Management Template

> **🔒 SECURITY WARNING:** Never store actual credentials in this file or commit them to Git!
> This is a TEMPLATE showing WHAT credentials you need and WHERE they should be stored.

## Purpose

This template helps you track:
- WHAT credentials are needed for your setup
- WHERE to store them securely (not the credentials themselves!)
- HOW to reference them in your applications

## ⚠️ NEVER Store in Git

**DO NOT** put any of the following in Git repositories:
- Passwords
- API keys
- Private keys
- RPC credentials
- Database passwords
- SSH keys
- Certificates

## Recommended Storage Solutions

### 1. Password Manager (Recommended for Personal Use)
- **1Password**: https://1password.com
- **Bitwarden**: https://bitwarden.com
- **LastPass**: https://lastpass.com
- **KeePass**: https://keepass.info

### 2. Secrets Management (Recommended for Production)
- **HashiCorp Vault**: For enterprise secrets management
- **AWS Secrets Manager**: If using AWS
- **Azure Key Vault**: If using Azure
- **Google Secret Manager**: If using Google Cloud

### 3. Environment Variables (For Development)
- Store in `.env` files (add to `.gitignore`)
- Load with dotenv or similar libraries
- Never commit `.env` to Git

### 4. Hardware Security (For Crypto Keys)
- **Ledger**: Hardware wallet for crypto keys
- **Trezor**: Hardware wallet for crypto keys
- **YubiKey**: For SSH and GPG keys

## Credentials Inventory Template

### Bitcoin Core Credentials

**Location to Store:** Password manager or secrets vault

```
Service: Bitcoin Core RPC
Location: ~/.bitcoin/bitcoin.conf
Stored in: [YOUR PASSWORD MANAGER NAME]
Entry name: "Bitcoin Core RPC - Production"

Credentials needed:
- rpcuser: [STORED IN PASSWORD MANAGER]
- rpcpassword: [STORED IN PASSWORD MANAGER]
- rpcport: [Usually 8332, can be plain text]

Environment variable reference:
- BITCOIN_RPC_USER
- BITCOIN_RPC_PASSWORD
- BITCOIN_RPC_HOST
- BITCOIN_RPC_PORT
```

**How to use:**
1. Generate strong password: `openssl rand -base64 32`
2. Store in password manager under "Bitcoin Core RPC - Production"
3. Add to bitcoin.conf (file is protected by OS permissions)
4. Reference in apps via environment variables

---

### Lightning Network (LND) Credentials

**Location to Store:** Password manager + secure file system

```
Service: LND (Lightning Network Daemon)
Location: ~/.lnd/
Stored in: [YOUR PASSWORD MANAGER NAME]
Entry name: "LND - Production"

Credentials needed:
- Wallet password: [STORED IN PASSWORD MANAGER]
- admin.macaroon: [STORED IN SECURE FILE SYSTEM - ~/.lnd/data/chain/bitcoin/mainnet/]
- tls.cert: [STORED IN SECURE FILE SYSTEM - ~/.lnd/]
- RPC host: [Usually localhost:10009, can be plain text]

Environment variable reference:
- LND_HOST
- LND_CERT_PATH
- LND_MACAROON_PATH
- LND_NETWORK (mainnet/testnet/signet)
```

**How to use:**
1. LND generates macaroon and cert files automatically
2. Store wallet password in password manager
3. Protect files with proper permissions: `chmod 600 ~/.lnd/admin.macaroon`
4. Never copy macaroon files outside of secure systems
5. Reference in apps via environment variables pointing to file paths

---

### Redis Credentials

**Location to Store:** Password manager or secrets vault

```
Service: Redis
Location: redis.conf or Docker environment
Stored in: [YOUR PASSWORD MANAGER NAME]
Entry name: "Redis - Production"

Credentials needed:
- Redis password: [STORED IN PASSWORD MANAGER]
- Redis host: [Usually localhost or redis service name]
- Redis port: [Usually 6379, can be plain text]

Environment variable reference:
- REDIS_HOST
- REDIS_PORT
- REDIS_PASSWORD
```

**How to use:**
1. Generate strong password: `openssl rand -base64 32`
2. Store in password manager
3. Set in redis.conf: `requirepass your_password`
4. Or pass via Docker: `docker run -e REDIS_PASSWORD=...`
5. Reference in apps via environment variables

---

### Tenderly API Credentials

**Location to Store:** Password manager or secrets vault

```
Service: Tenderly.co API
Location: Tenderly account settings
Stored in: [YOUR PASSWORD MANAGER NAME]
Entry name: "Tenderly API - Production"

Credentials needed:
- API Key: [STORED IN PASSWORD MANAGER]
- Project ID: [STORED IN PASSWORD MANAGER]
- Account ID: [Can be plain text in some cases]

Environment variable reference:
- TENDERLY_API_KEY
- TENDERLY_PROJECT_ID
- TENDERLY_ACCOUNT_ID
```

**How to use:**
1. Generate API key from Tenderly dashboard
2. Store immediately in password manager
3. Never log or display in application
4. Rotate keys regularly (every 90 days recommended)
5. Reference in apps via environment variables

---

### Database Credentials

**Location to Store:** Password manager or secrets vault

```
Service: PostgreSQL/MySQL/MongoDB
Location: Database configuration
Stored in: [YOUR PASSWORD MANAGER NAME]
Entry name: "Database - Production"

Credentials needed:
- Database username: [STORED IN PASSWORD MANAGER]
- Database password: [STORED IN PASSWORD MANAGER]
- Database host: [Can be plain text]
- Database port: [Can be plain text]
- Database name: [Can be plain text]

Environment variable reference:
- DB_USER
- DB_PASSWORD
- DB_HOST
- DB_PORT
- DB_NAME
```

**How to use:**
1. Create database user with minimal required privileges
2. Generate strong password
3. Store in password manager
4. Use connection strings with environment variables
5. Never hardcode in application code

---

### SSH Keys

**Location to Store:** Secure file system + password manager for passphrases

```
Service: SSH Access
Location: ~/.ssh/
Stored in: Secure file system with proper permissions
Entry name: "SSH Keys - Production Servers"

Credentials needed:
- Private key: [STORED IN ~/.ssh/ with 600 permissions]
- Passphrase: [STORED IN PASSWORD MANAGER]
- Public key: [Can be shared]

File locations:
- Private key: ~/.ssh/id_rsa or ~/.ssh/id_ed25519
- Public key: ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub
```

**How to use:**
1. Generate key pair: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Set strong passphrase (store in password manager)
3. Set proper permissions: `chmod 600 ~/.ssh/id_ed25519`
4. Add public key to authorized servers
5. Use ssh-agent for key management

---

### SSL/TLS Certificates

**Location to Store:** Secure file system + password manager for private keys

```
Service: SSL/TLS Certificates
Location: /etc/ssl/ or application-specific directory
Stored in: Secure file system with proper permissions
Entry name: "SSL Certificates - domain.com"

Credentials needed:
- Private key (.key): [STORED IN SECURE FILE SYSTEM - 600 permissions]
- Certificate (.crt/.pem): [Can be less restrictive - 644 permissions]
- CA bundle: [Public, 644 permissions]

File locations:
- Private key: /etc/ssl/private/domain.key
- Certificate: /etc/ssl/certs/domain.crt
- CA bundle: /etc/ssl/certs/ca-bundle.crt
```

**How to use:**
1. Obtain from Certificate Authority (Let's Encrypt, etc.)
2. Store private key with 600 permissions
3. Never commit to Git
4. Set up automatic renewal
5. Monitor expiration dates

---

## Environment Variables Setup

### Development (.env file)

Create `.env` file in your project root (ensure it's in `.gitignore`):

```bash
# Bitcoin Core
BITCOIN_RPC_USER=your_rpc_username
BITCOIN_RPC_PASSWORD=your_rpc_password
BITCOIN_RPC_HOST=127.0.0.1
BITCOIN_RPC_PORT=8332

# Lightning Network
LND_HOST=localhost:10009
LND_CERT_PATH=/home/username/.lnd/tls.cert
LND_MACAROON_PATH=/home/username/.lnd/data/chain/bitcoin/mainnet/admin.macaroon

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# Tenderly
TENDERLY_API_KEY=your_api_key
TENDERLY_PROJECT_ID=your_project_id

# Database
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database
```

**Never commit this file to Git!**

### Production (System Environment Variables)

For production, set system-wide or user-specific environment variables:

**Linux/macOS (.bashrc or .profile):**

```bash
# Add to ~/.bashrc or ~/.profile
export BITCOIN_RPC_USER="your_rpc_username"
export BITCOIN_RPC_PASSWORD="your_rpc_password"
export REDIS_PASSWORD="your_redis_password"
# ... etc
```

**Docker Compose (environment section):**

```yaml
services:
  app:
    environment:
      - BITCOIN_RPC_USER=${BITCOIN_RPC_USER}
      - BITCOIN_RPC_PASSWORD=${BITCOIN_RPC_PASSWORD}
      # ... etc
```

**Kubernetes (secrets):**

```bash
kubectl create secret generic app-secrets \
  --from-literal=bitcoin-rpc-user='your_username' \
  --from-literal=bitcoin-rpc-password='your_password'
```

---

## Security Best Practices

### 1. Password Generation

**Use strong, unique passwords for each service:**

```bash
# Generate 32-character password
openssl rand -base64 32

# Generate 64-character password
openssl rand -base64 64

# Generate alphanumeric password
openssl rand -hex 32
```

### 2. Regular Rotation

**Rotate credentials periodically:**

- API keys: Every 90 days
- Passwords: Every 180 days
- SSH keys: Every year or when compromised
- Certificates: Before expiration (automated with Let's Encrypt)

### 3. Access Control

**Limit who can access credentials:**

- Use role-based access control (RBAC)
- Implement principle of least privilege
- Audit access logs regularly
- Revoke access immediately when team members leave

### 4. File Permissions

**Set proper permissions on sensitive files:**

```bash
# Private keys and credentials (read/write for owner only)
chmod 600 ~/.bitcoin/bitcoin.conf
chmod 600 ~/.lnd/admin.macaroon
chmod 600 ~/.ssh/id_ed25519
chmod 600 .env

# Directories (read/write/execute for owner only)
chmod 700 ~/.bitcoin
chmod 700 ~/.lnd
chmod 700 ~/.ssh
```

### 5. Monitoring and Alerting

**Monitor for credential misuse:**

- Set up alerts for failed authentication attempts
- Monitor unusual access patterns
- Use intrusion detection systems
- Review audit logs regularly

### 6. Incident Response

**If credentials are compromised:**

1. **Immediately** revoke/rotate the compromised credentials
2. Review access logs to determine scope of breach
3. Change all related credentials
4. Notify affected parties if required
5. Conduct post-mortem to prevent recurrence

---

## Testing Credentials Safely

### Never Use Production Credentials in Development

**Create separate credentials for each environment:**

- **Development**: localhost, weak security OK
- **Staging**: mimics production, separate credentials
- **Production**: strong security, monitored access

### Mock Services for Testing

**Use mocks instead of real services:**

```javascript
// Example: Mock Bitcoin RPC for testing
if (process.env.NODE_ENV === 'test') {
  // Use mock RPC client
  const mockRpc = {
    getBlockchainInfo: () => Promise.resolve({ blocks: 800000 })
  };
} else {
  // Use real RPC client with credentials
  const rpc = new BitcoinRPC({
    user: process.env.BITCOIN_RPC_USER,
    password: process.env.BITCOIN_RPC_PASSWORD
  });
}
```

---

## Credential Recovery

### If You Lose Credentials

**Bitcoin Core:**
- RPC credentials: Can regenerate in bitcoin.conf
- Wallet: CRITICAL - if lost, funds are unrecoverable. ALWAYS backup wallet.dat

**Lightning Network:**
- Wallet password: Use seed phrase to recover
- Macaroons: Can regenerate, but will invalidate existing auth
- Channel backups: CRITICAL - backup channel.backup regularly

**API Keys:**
- Can usually regenerate from service dashboard
- Old keys may continue working until explicitly revoked

**Database Passwords:**
- Can reset through database admin tools
- May cause temporary service disruption

---

## Credential Backup Strategy

### What to Backup

**Critical (must backup):**
- Bitcoin Core wallet.dat
- LND seed phrase (24 words)
- LND channel backups
- SSL/TLS private keys
- SSH private keys

**Important (should backup):**
- Configuration files (sanitized of credentials)
- Environment variable templates
- Password manager database

**Do NOT backup in plain text:**
- Current passwords
- API keys
- Database credentials

### Backup Methods

**Encrypted Cloud Backup:**
```bash
# Encrypt before uploading
tar -czf backup.tar.gz ~/.bitcoin/wallet.dat
gpg --encrypt --recipient your@email.com backup.tar.gz
# Upload backup.tar.gz.gpg to cloud
```

**Hardware Backup:**
- USB drives stored in safe
- Hardware wallets for crypto keys
- Paper backups for seed phrases

**Geographic Redundancy:**
- Store backups in multiple physical locations
- Use different backup media types
- Test recovery regularly

---

## Tools and Scripts

### Environment Variables Helper Script

Create `load-env.sh`:

```bash
#!/bin/bash
# Load environment variables from password manager or secrets vault
# This script should NOT contain actual credentials

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "Environment variables loaded from .env"
else
    echo "Error: .env file not found"
    exit 1
fi
```

Usage:
```bash
source load-env.sh
```

### Credential Checker Script

Create `check-credentials.sh`:

```bash
#!/bin/bash
# Check if required environment variables are set

REQUIRED_VARS=(
    "BITCOIN_RPC_USER"
    "BITCOIN_RPC_PASSWORD"
    "REDIS_PASSWORD"
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

echo "All required credentials are set"
```

---

## Additional Resources

### Documentation
- [Bitcoin Core Security](https://bitcoin.org/en/secure-your-wallet)
- [LND Security Best Practices](https://docs.lightning.engineering/lightning-network-tools/lnd/safety)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)

### Tools
- [git-secrets](https://github.com/awslabs/git-secrets) - Prevents committing secrets
- [truffleHog](https://github.com/trufflesecurity/trufflehog) - Scans for secrets in git history
- [detect-secrets](https://github.com/Yelp/detect-secrets) - Prevents secrets from entering codebase

---

## Checklist

Use this checklist to ensure proper credential management:

- [ ] All credentials stored in password manager or secrets vault
- [ ] No credentials committed to Git repository
- [ ] `.env` files added to `.gitignore`
- [ ] File permissions set correctly (600 for sensitive files)
- [ ] Environment variables configured for all environments
- [ ] Strong passwords generated using secure methods
- [ ] SSH keys protected with passphrases
- [ ] Wallet backups created and tested
- [ ] Credential rotation schedule established
- [ ] Access control policies implemented
- [ ] Monitoring and alerting configured
- [ ] Incident response plan documented
- [ ] Team trained on security best practices

---

## Support

For questions about credential management:
- Review project documentation in `doc/` directory
- Check `.gitignore` for files that should not be committed
- Review security best practices in integration guides

**Remember:** When in doubt, DO NOT commit. It's better to ask than to leak credentials!
