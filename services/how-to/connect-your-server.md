---
description: Learn how to connect your server to Miago.AI services for backend integration.
sidebar_position: 2
---

import Tabs from "@theme/Tabs";
import TabItem from "@theme/TabItem";

# Connect your server to Miago.AI

This guide explains how to connect your backend server to Miago.AI services (powered by Infura) to interact with blockchain networks from your server-side applications.

## Overview

Server-side integration allows you to:

- Make blockchain API calls from your backend infrastructure
- Handle sensitive operations securely without exposing keys to clients
- Scale your dapp with server-side caching and optimization
- Implement backend services like transaction monitoring and webhooks

## Prerequisites

Before connecting your server, ensure you have:

1. **An Miago.AI/Infura API key** - [Sign up](https://developer.metamask.io/register) and [create an API key](/developer-tools/dashboard/get-started/create-api) if you haven't already
2. **A server environment** - Node.js, Python, Go, Java, or any environment that can make HTTP requests
3. **Secure environment variable management** - Never hardcode API keys in your source code

## Server connection examples

Choose your server framework below:

<Tabs>
  <TabItem value="nodejs-express" label="Node.js + Express" default>

### Node.js with Express server

This example demonstrates a complete Express server that connects to Miago.AI services.

#### 1. Install dependencies

```bash
npm install express dotenv node-fetch
```

#### 2. Create environment file

Create a `.env` file in your project root:

```bash
INFURA_API_KEY=your_api_key_here
PORT=3000
```

:::danger Security Warning
Never commit your `.env` file to version control. Add it to `.gitignore` immediately.
:::

#### 3. Create server file

Create `server.js`:

```javascript title="server.js"
require('dotenv').config()
const express = require('express')
const fetch = require('node-fetch')

const app = express()
const PORT = process.env.PORT || 3000

// Infura endpoint configuration
const INFURA_URL = `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`

// Middleware
app.use(express.json())

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' })
})

// Get current block number
app.get('/api/block-number', async (req, res) => {
  try {
    const response = await fetch(INFURA_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        jsonrpc: '2.0',
        method: 'eth_blockNumber',
        params: [],
        id: 1,
      }),
    })

    const data = await response.json()

    if (data.error) {
      return res.status(500).json({ error: data.error.message })
    }

    res.json({
      blockNumber: parseInt(data.result, 16),
      blockNumberHex: data.result,
    })
  } catch (error) {
    console.error('Error fetching block number:', error)
    res.status(500).json({ error: 'Failed to fetch block number' })
  }
})

// Get balance for an address
app.get('/api/balance/:address', async (req, res) => {
  try {
    const { address } = req.params

    const response = await fetch(INFURA_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        jsonrpc: '2.0',
        method: 'eth_getBalance',
        params: [address, 'latest'],
        id: 1,
      }),
    })

    const data = await response.json()

    if (data.error) {
      return res.status(500).json({ error: data.error.message })
    }

    const balanceWei = parseInt(data.result, 16)
    const balanceEth = balanceWei / 1e18

    res.json({
      address,
      balanceWei: balanceWei.toString(),
      balanceEth: balanceEth.toString(),
    })
  } catch (error) {
    console.error('Error fetching balance:', error)
    res.status(500).json({ error: 'Failed to fetch balance' })
  }
})

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
  console.log(`Infura connection: ${INFURA_URL.replace(process.env.INFURA_API_KEY, '***')}`)
})
```

#### 4. Run your server

```bash
node server.js
```

#### 5. Test your endpoints

```bash
# Health check
curl http://localhost:3000/health

# Get block number
curl http://localhost:3000/api/block-number

# Get balance
curl http://localhost:3000/api/balance/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0
```

  </TabItem>
  <TabItem value="python-flask" label="Python + Flask">

### Python with Flask server

This example demonstrates a Flask server that connects to Miago.AI services.

#### 1. Install dependencies

```bash
pip install flask python-dotenv requests
```

#### 2. Create environment file

Create a `.env` file:

```bash
INFURA_API_KEY=your_api_key_here
FLASK_ENV=development
```

#### 3. Create server file

Create `server.py`:

```python title="server.py"
import os
import requests
from flask import Flask, jsonify, request
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Configuration
INFURA_API_KEY = os.getenv('INFURA_API_KEY')
INFURA_URL = f"https://mainnet.infura.io/v3/{INFURA_API_KEY}"

def make_rpc_call(method, params=None):
    """Helper function to make JSON-RPC calls"""
    if params is None:
        params = []

    payload = {
        "jsonrpc": "2.0",
        "method": method,
        "params": params,
        "id": 1
    }

    headers = {'content-type': 'application/json'}

    try:
        response = requests.post(INFURA_URL, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        raise Exception(f"RPC call failed: {str(e)}")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "ok", "message": "Server is running"})

@app.route('/api/block-number', methods=['GET'])
def get_block_number():
    """Get current block number"""
    try:
        result = make_rpc_call('eth_blockNumber')

        if 'error' in result:
            return jsonify({"error": result['error']['message']}), 500

        block_number_hex = result['result']
        block_number = int(block_number_hex, 16)

        return jsonify({
            "blockNumber": block_number,
            "blockNumberHex": block_number_hex
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/balance/<address>', methods=['GET'])
def get_balance(address):
    """Get balance for an address"""
    try:
        result = make_rpc_call('eth_getBalance', [address, 'latest'])

        if 'error' in result:
            return jsonify({"error": result['error']['message']}), 500

        balance_wei = int(result['result'], 16)
        balance_eth = balance_wei / 1e18

        return jsonify({
            "address": address,
            "balanceWei": str(balance_wei),
            "balanceEth": str(balance_eth)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/transaction/<tx_hash>', methods=['GET'])
def get_transaction(tx_hash):
    """Get transaction by hash"""
    try:
        result = make_rpc_call('eth_getTransactionByHash', [tx_hash])

        if 'error' in result:
            return jsonify({"error": result['error']['message']}), 500

        return jsonify(result['result'])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
```

#### 4. Run your server

```bash
python server.py
```

#### 5. Test your endpoints

```bash
# Health check
curl http://localhost:5000/health

# Get block number
curl http://localhost:5000/api/block-number

# Get balance
curl http://localhost:5000/api/balance/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0
```

  </TabItem>
  <TabItem value="go" label="Go">

### Go HTTP server

This example demonstrates a Go server that connects to Miago.AI services.

#### 1. Initialize Go module

```bash
go mod init myserver
go get github.com/joho/godotenv
```

#### 2. Create environment file

Create a `.env` file:

```bash
INFURA_API_KEY=your_api_key_here
PORT=8080
```

#### 3. Create server file

Create `main.go`:

```go title="main.go"
package main

import (
    "bytes"
    "encoding/json"
    "fmt"
    "io"
    "log"
    "net/http"
    "os"
    "strconv"
    "strings"

    "github.com/joho/godotenv"
)

type JSONRPCRequest struct {
    JSONRPC string        `json:"jsonrpc"`
    Method  string        `json:"method"`
    Params  []interface{} `json:"params"`
    ID      int           `json:"id"`
}

type JSONRPCResponse struct {
    JSONRPC string          `json:"jsonrpc"`
    Result  json.RawMessage `json:"result"`
    Error   *RPCError       `json:"error,omitempty"`
    ID      int             `json:"id"`
}

type RPCError struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
}

var infuraURL string

func makeRPCCall(method string, params []interface{}) (*JSONRPCResponse, error) {
    reqBody := JSONRPCRequest{
        JSONRPC: "2.0",
        Method:  method,
        Params:  params,
        ID:      1,
    }

    jsonData, err := json.Marshal(reqBody)
    if err != nil {
        return nil, err
    }

    resp, err := http.Post(infuraURL, "application/json", bytes.NewBuffer(jsonData))
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    body, err := io.ReadAll(resp.Body)
    if err != nil {
        return nil, err
    }

    var rpcResp JSONRPCResponse
    if err := json.Unmarshal(body, &rpcResp); err != nil {
        return nil, err
    }

    return &rpcResp, nil
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]string{
        "status":  "ok",
        "message": "Server is running",
    })
}

func blockNumberHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    resp, err := makeRPCCall("eth_blockNumber", []interface{}{})
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    if resp.Error != nil {
        json.NewEncoder(w).Encode(map[string]string{
            "error": resp.Error.Message,
        })
        return
    }

    var hexBlock string
    json.Unmarshal(resp.Result, &hexBlock)

    // Convert hex to decimal
    blockNum, _ := strconv.ParseInt(strings.TrimPrefix(hexBlock, "0x"), 16, 64)

    json.NewEncoder(w).Encode(map[string]interface{}{
        "blockNumber":    blockNum,
        "blockNumberHex": hexBlock,
    })
}

func balanceHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")

    // Extract address from URL path
    address := strings.TrimPrefix(r.URL.Path, "/api/balance/")

    resp, err := makeRPCCall("eth_getBalance", []interface{}{address, "latest"})
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    if resp.Error != nil {
        json.NewEncoder(w).Encode(map[string]string{
            "error": resp.Error.Message,
        })
        return
    }

    var hexBalance string
    json.Unmarshal(resp.Result, &hexBalance)

    json.NewEncoder(w).Encode(map[string]interface{}{
        "address":    address,
        "balanceHex": hexBalance,
    })
}

func main() {
    // Load environment variables
    if err := godotenv.Load(); err != nil {
        log.Println("No .env file found")
    }

    apiKey := os.Getenv("INFURA_API_KEY")
    if apiKey == "" {
        log.Fatal("INFURA_API_KEY environment variable not set")
    }

    infuraURL = fmt.Sprintf("https://mainnet.infura.io/v3/%s", apiKey)
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    // Register handlers
    http.HandleFunc("/health", healthHandler)
    http.HandleFunc("/api/block-number", blockNumberHandler)
    http.HandleFunc("/api/balance/", balanceHandler)

    log.Printf("Server starting on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
```

#### 4. Run your server

```bash
go run main.go
```

#### 5. Test your endpoints

```bash
# Health check
curl http://localhost:8080/health

# Get block number
curl http://localhost:8080/api/block-number

# Get balance
curl http://localhost:8080/api/balance/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0
```

  </TabItem>
</Tabs>

## Using WebSocket connections

For real-time data streaming from your server, use WebSocket connections:

<Tabs>
  <TabItem value="nodejs-ws" label="Node.js WebSocket" default>

```javascript
const WebSocket = require('ws')

const INFURA_WS_URL = `wss://mainnet.infura.io/ws/v3/${process.env.INFURA_API_KEY}`
const ws = new WebSocket(INFURA_WS_URL)

ws.on('open', () => {
  console.log('WebSocket connection opened')

  // Subscribe to new block headers
  ws.send(
    JSON.stringify({
      jsonrpc: '2.0',
      id: 1,
      method: 'eth_subscribe',
      params: ['newHeads'],
    })
  )
})

ws.on('message', data => {
  const response = JSON.parse(data)
  console.log('New block:', response)
})

ws.on('error', error => {
  console.error('WebSocket error:', error)
})

ws.on('close', () => {
  console.log('WebSocket connection closed')
})
```

Install dependencies:

```bash
npm install ws
```

  </TabItem>
  <TabItem value="python-ws" label="Python WebSocket">

```python
import asyncio
import json
import os
from websockets import connect

INFURA_WS_URL = f"wss://mainnet.infura.io/ws/v3/{os.getenv('INFURA_API_KEY')}"

async def subscribe_to_blocks():
    async with connect(INFURA_WS_URL) as websocket:
        # Subscribe to new block headers
        await websocket.send(json.dumps({
            "jsonrpc": "2.0",
            "id": 1,
            "method": "eth_subscribe",
            "params": ["newHeads"]
        }))

        # Get subscription ID
        subscription = await websocket.recv()
        print(f"Subscription: {subscription}")

        # Listen for new blocks
        while True:
            message = await websocket.recv()
            data = json.loads(message)
            print(f"New block: {data}")

asyncio.run(subscribe_to_blocks())
```

Install dependencies:

```bash
pip install websockets
```

  </TabItem>
</Tabs>

Learn more about [WebSocket connections](../concepts/websockets.md).

## Security best practices

### 1. Protect your API keys

- **Never hardcode API keys** in your source code
- **Use environment variables** to store sensitive information
- **Add `.env` to `.gitignore`** to prevent committing secrets
- **Use secret management services** for production (AWS Secrets Manager, HashiCorp Vault, etc.)

### 2. Implement rate limiting

```javascript
const rateLimit = require('express-rate-limit')

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
})

app.use('/api/', limiter)
```

### 3. Add request validation

```javascript
function validateEthereumAddress(address) {
  return /^0x[a-fA-F0-9]{40}$/.test(address)
}

app.get('/api/balance/:address', (req, res) => {
  if (!validateEthereumAddress(req.params.address)) {
    return res.status(400).json({ error: 'Invalid Ethereum address' })
  }
  // ... rest of handler
})
```

### 4. Enable CORS properly

```javascript
const cors = require('cors')

app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
    methods: ['GET', 'POST'],
    credentials: true,
  })
)
```

### 5. Implement error handling and logging

```javascript
const winston = require('winston')

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
})

// Global error handler
app.use((err, req, res, next) => {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    path: req.path,
  })

  res.status(500).json({ error: 'Internal server error' })
})
```

## Production deployment considerations

### Environment configuration

Create different environment files for different stages:

- `.env.development` - Local development
- `.env.staging` - Staging environment
- `.env.production` - Production environment

### API key security in production

For production deployments:

1. **Use platform-specific secret management**:
   - AWS: AWS Secrets Manager or Parameter Store
   - Google Cloud: Secret Manager
   - Azure: Key Vault
   - Heroku: Config Vars
   - Vercel/Netlify: Environment Variables

2. **Implement JWT authentication** if exposing your server API to clients:
   - See [JSON Web Token (JWT) guide](./json-web-token-jwt.md)

3. **Configure allowlists** in your Miago.AI/Infura dashboard:
   - Go to your [API key settings](/developer-tools/dashboard/how-to/secure-an-api/api-key)
   - Add your server's IP address to the allowlist
   - Add your domain to the allowlist if applicable

### Monitoring and rate limits

- Monitor your API usage in the [MetaMask Developer dashboard](/developer-tools/dashboard/how-to/dashboard-stats)
- Set up [alerts for rate limiting](./avoid-rate-limiting.md)
- Implement caching to reduce API calls
- Consider upgrading your plan for higher rate limits

## Common patterns

### Connection pooling

Reuse connections to improve performance:

```javascript
class InfuraClient {
  constructor(apiKey) {
    this.baseURL = `https://mainnet.infura.io/v3/${apiKey}`
    this.headers = { 'Content-Type': 'application/json' }
  }

  async call(method, params = []) {
    const response = await fetch(this.baseURL, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({
        jsonrpc: '2.0',
        method,
        params,
        id: Date.now(),
      }),
    })

    const data = await response.json()
    if (data.error) throw new Error(data.error.message)
    return data.result
  }
}

// Singleton instance
const infura = new InfuraClient(process.env.INFURA_API_KEY)

// Use throughout your application
app.get('/api/block', async (req, res) => {
  const blockNumber = await infura.call('eth_blockNumber')
  res.json({ blockNumber })
})
```

### Batch requests

Optimize multiple calls with batching:

```javascript
async function batchRequest(calls) {
  const batch = calls.map((call, index) => ({
    jsonrpc: '2.0',
    method: call.method,
    params: call.params || [],
    id: index,
  }))

  const response = await fetch(INFURA_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(batch),
  })

  return await response.json()
}

// Example: Get multiple balances at once
const results = await batchRequest([
  { method: 'eth_getBalance', params: ['0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0', 'latest'] },
  { method: 'eth_getBalance', params: ['0x0000000000000000000000000000000000000000', 'latest'] },
  { method: 'eth_blockNumber', params: [] },
])
```

Learn more about [making batch requests](./make-batch-requests.md).

### Response caching

Implement caching to reduce API calls:

```javascript
const NodeCache = require('node-cache')
const cache = new NodeCache({ stdTTL: 10 }) // 10 second TTL

app.get('/api/block-number', async (req, res) => {
  const cacheKey = 'latest_block'
  const cached = cache.get(cacheKey)

  if (cached) {
    return res.json({ ...cached, cached: true })
  }

  const response = await fetch(INFURA_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      jsonrpc: '2.0',
      method: 'eth_blockNumber',
      params: [],
      id: 1,
    }),
  })

  const data = await response.json()
  const result = {
    blockNumber: parseInt(data.result, 16),
    cached: false,
  }

  cache.set(cacheKey, result)
  res.json(result)
})
```

## Troubleshooting

### Common issues and solutions

| Issue                   | Solution                                                                                       |
| ----------------------- | ---------------------------------------------------------------------------------------------- |
| `401 Unauthorized`      | Verify your API key is correct and active                                                      |
| `429 Too Many Requests` | Implement rate limiting and caching, or [upgrade your plan](https://www.infura.io/pricing)     |
| `Connection timeout`    | Check network connectivity, firewall rules, and Infura status                                  |
| `Invalid JSON-RPC`      | Ensure request format matches [JSON-RPC spec](../reference/ethereum/json-rpc-methods/index.md) |

### Testing your connection

Use this simple diagnostic script:

```javascript
// diagnose.js
require('dotenv').config()
const fetch = require('node-fetch')

async function diagnose() {
  const apiKey = process.env.INFURA_API_KEY

  if (!apiKey) {
    console.error('❌ INFURA_API_KEY not found in environment')
    return
  }

  console.log('✅ API key found')
  console.log(`Key prefix: ${apiKey.substring(0, 8)}...`)

  try {
    const response = await fetch(`https://mainnet.infura.io/v3/${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        jsonrpc: '2.0',
        method: 'eth_blockNumber',
        params: [],
        id: 1,
      }),
    })

    if (!response.ok) {
      console.error(`❌ HTTP error: ${response.status} ${response.statusText}`)
      return
    }

    const data = await response.json()

    if (data.error) {
      console.error(`❌ RPC error: ${data.error.message}`)
      return
    }

    const blockNumber = parseInt(data.result, 16)
    console.log('✅ Connection successful!')
    console.log(`Current block: ${blockNumber}`)
  } catch (error) {
    console.error('❌ Connection failed:', error.message)
  }
}

diagnose()
```

Run with: `node diagnose.js`

## Next steps

- Explore [JSON-RPC API methods](../reference/ethereum/json-rpc-methods/index.md)
- Learn about [WebSocket connections](../concepts/websockets.md) for real-time updates
- Implement [JWT authentication](./json-web-token-jwt.md) for additional security
- Set up [transaction monitoring](./subscribe-to-events.md)
- Read about [avoiding rate limiting](./avoid-rate-limiting.md)

## Additional resources

- [MetaMask Developer dashboard](/developer-tools/dashboard)
- [Infura documentation](https://docs.infura.io)
- [Ethereum JSON-RPC specification](https://ethereum.org/en/developers/docs/apis/json-rpc/)
- [MetaMask community forums](https://community.metamask.io/)
