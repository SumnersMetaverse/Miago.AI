---
description: Create a dapp that integrates MetaMask with 1inch DEX aggregator.
---

# Create a 1inch swap dapp

This tutorial walks you through creating a simple dapp that integrates MetaMask with the
[1inch](https://1inch.io/) decentralized exchange (DEX) aggregator.
The dapp allows users to connect their MetaMask wallet and swap tokens using 1inch's API to find
the best exchange rates across multiple DEXs.

:::info What is 1inch?
1inch is a DEX aggregator that sources liquidity from various exchanges to offer users the best
rates on token swaps.
By aggregating multiple DEXs, 1inch helps users save on gas fees and get better exchange rates for
their trades.
:::

## Prerequisites

- [Node.js](https://nodejs.org/) version 20+
- [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) version 9+
- A text editor (for example, [VS Code](https://code.visualstudio.com/))
- The [MetaMask extension](https://metamask.io/download) installed
- Basic knowledge of JavaScript and React
- A 1inch API key (you can obtain one from the [1inch Developer Portal](https://portal.1inch.dev/))

## Steps

### 1. Set up the project

Create a new project using [Vite](https://vitejs.dev/guide/):

```bash
npm create vite@latest 1inch-swap-dapp -- --template react
```

Change into your project directory and install dependencies:

```bash
cd 1inch-swap-dapp && npm install
```

Install additional dependencies for interacting with Ethereum and 1inch:

```bash
npm install ethers
```

Launch the development server:

```bash
npm run dev
```

This displays a `localhost` URL in your terminal where you can view the dapp in your browser.

### 2. Set up environment variables

Create a `.env` file in your project root to store your 1inch API key:

```bash
VITE_ONEINCH_API_KEY=your_api_key_here
```

:::caution
Never commit your `.env` file to version control.
Add it to your `.gitignore` file to keep your API keys secure.
:::

### 3. Create the wallet connection component

Create a `src/components` directory and add a `WalletConnect.jsx` file:

```jsx title="WalletConnect.jsx"
import { useState, useEffect } from 'react'
import { ethers } from 'ethers'

function WalletConnect({ onConnect }) {
  const [account, setAccount] = useState(null)
  const [chainId, setChainId] = useState(null)

  useEffect(() => {
    checkConnection()
    
    if (window.ethereum) {
      window.ethereum.on('accountsChanged', handleAccountsChanged)
      window.ethereum.on('chainChanged', handleChainChanged)
    }

    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged)
        window.ethereum.removeListener('chainChanged', handleChainChanged)
      }
    }
  }, [])

  async function checkConnection() {
    if (window.ethereum) {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum)
        const accounts = await provider.listAccounts()
        
        if (accounts.length > 0) {
          const network = await provider.getNetwork()
          setAccount(accounts[0].address)
          setChainId(network.chainId.toString())
          onConnect(provider, accounts[0].address)
        }
      } catch (error) {
        console.error('Error checking connection:', error)
      }
    }
  }

  async function connectWallet() {
    if (typeof window.ethereum === 'undefined') {
      alert('Please install MetaMask to use this dapp')
      return
    }

    try {
      const provider = new ethers.BrowserProvider(window.ethereum)
      const accounts = await provider.send('eth_requestAccounts', [])
      const network = await provider.getNetwork()
      
      setAccount(accounts[0])
      setChainId(network.chainId.toString())
      onConnect(provider, accounts[0])
    } catch (error) {
      console.error('Error connecting wallet:', error)
      alert('Failed to connect wallet')
    }
  }

  function handleAccountsChanged(accounts) {
    if (accounts.length === 0) {
      setAccount(null)
      onConnect(null, null)
    } else {
      setAccount(accounts[0])
      checkConnection()
    }
  }

  function handleChainChanged() {
    window.location.reload()
  }

  return (
    <div className="wallet-connect">
      {account ? (
        <div>
          <p>Connected: {account.slice(0, 6)}...{account.slice(-4)}</p>
          <p>Chain ID: {chainId}</p>
        </div>
      ) : (
        <button onClick={connectWallet}>Connect MetaMask</button>
      )}
    </div>
  )
}

export default WalletConnect
```

### 4. Create the token swap component

Create a `TokenSwap.jsx` file in the `src/components` directory:

```jsx title="TokenSwap.jsx"
import { useState, useEffect } from 'react'
import { ethers } from 'ethers'

function TokenSwap({ provider, account }) {
  const [fromToken, setFromToken] = useState('0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE') // ETH
  const [toToken, setToToken] = useState('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48') // USDC
  const [amount, setAmount] = useState('')
  const [quote, setQuote] = useState(null)
  const [loading, setLoading] = useState(false)
  const chainId = 1 // Ethereum mainnet

  const API_KEY = import.meta.env.VITE_ONEINCH_API_KEY

  async function getQuote() {
    if (!amount || !fromToken || !toToken) return

    setLoading(true)
    try {
      const amountInWei = ethers.parseEther(amount).toString()
      
      const response = await fetch(
        `https://api.1inch.dev/swap/v6.0/${chainId}/quote?` +
        `src=${fromToken}&dst=${toToken}&amount=${amountInWei}`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`,
            'Accept': 'application/json'
          }
        }
      )

      if (!response.ok) {
        throw new Error('Failed to fetch quote')
      }

      const data = await response.json()
      setQuote(data)
    } catch (error) {
      console.error('Error getting quote:', error)
      alert('Failed to get quote from 1inch')
    } finally {
      setLoading(false)
    }
  }

  async function executeSwap() {
    if (!provider || !account || !quote) return

    setLoading(true)
    try {
      const amountInWei = ethers.parseEther(amount).toString()
      
      const response = await fetch(
        `https://api.1inch.dev/swap/v6.0/${chainId}/swap?` +
        `src=${fromToken}&dst=${toToken}&amount=${amountInWei}&from=${account}&slippage=1`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`,
            'Accept': 'application/json'
          }
        }
      )

      if (!response.ok) {
        throw new Error('Failed to build swap transaction')
      }

      const swapData = await response.json()
      const signer = await provider.getSigner()
      
      const tx = await signer.sendTransaction({
        to: swapData.tx.to,
        data: swapData.tx.data,
        value: swapData.tx.value,
        gasLimit: swapData.tx.gas
      })

      alert(`Transaction submitted! Hash: ${tx.hash}`)
      await tx.wait()
      alert('Swap completed successfully!')
    } catch (error) {
      console.error('Error executing swap:', error)
      alert('Failed to execute swap')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="token-swap">
      <h2>Token Swap</h2>
      
      <div className="swap-form">
        <div className="input-group">
          <label>From Token (Address)</label>
          <input
            type="text"
            value={fromToken}
            onChange={(e) => setFromToken(e.target.value)}
            placeholder="Token contract address"
          />
        </div>

        <div className="input-group">
          <label>To Token (Address)</label>
          <input
            type="text"
            value={toToken}
            onChange={(e) => setToToken(e.target.value)}
            placeholder="Token contract address"
          />
        </div>

        <div className="input-group">
          <label>Amount</label>
          <input
            type="text"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="0.0"
          />
        </div>

        <button onClick={getQuote} disabled={loading || !account}>
          {loading ? 'Loading...' : 'Get Quote'}
        </button>

        {quote && (
          <div className="quote-result">
            <h3>Quote Result</h3>
            <p>Estimated Output: {ethers.formatUnits(quote.dstAmount, 6)} tokens</p>
            <button onClick={executeSwap} disabled={loading}>
              {loading ? 'Swapping...' : 'Execute Swap'}
            </button>
          </div>
        )}
      </div>
    </div>
  )
}

export default TokenSwap
```

### 5. Update the main App component

Replace the content of `src/App.jsx` with the following:

```jsx title="App.jsx"
import { useState } from 'react'
import WalletConnect from './components/WalletConnect'
import TokenSwap from './components/TokenSwap'
import './App.css'

function App() {
  const [provider, setProvider] = useState(null)
  const [account, setAccount] = useState(null)

  function handleConnect(newProvider, newAccount) {
    setProvider(newProvider)
    setAccount(newAccount)
  }

  return (
    <div className="App">
      <header>
        <h1>1inch Swap Dapp</h1>
        <p>Swap tokens using MetaMask and 1inch DEX aggregator</p>
      </header>
      
      <main>
        <WalletConnect onConnect={handleConnect} />
        
        {account ? (
          <TokenSwap provider={provider} account={account} />
        ) : (
          <p>Please connect your wallet to continue</p>
        )}
      </main>
    </div>
  )
}

export default App
```

### 6. Add styling

Update `src/App.css` to add some basic styling:

```css title="App.css"
.App {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}

header {
  margin-bottom: 2rem;
}

.wallet-connect {
  margin: 2rem 0;
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 8px;
}

.wallet-connect button {
  background-color: #f6851b;
  color: white;
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

.wallet-connect button:hover {
  background-color: #e2761b;
}

.token-swap {
  margin-top: 2rem;
  padding: 2rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  text-align: left;
}

.swap-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.input-group label {
  font-weight: bold;
  font-size: 0.9rem;
}

.input-group input {
  padding: 0.75rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 1rem;
}

.swap-form button {
  background-color: #94b9ff;
  color: #001f5c;
  padding: 0.75rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
}

.swap-form button:hover:not(:disabled) {
  background-color: #7ba4ff;
}

.swap-form button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.quote-result {
  margin-top: 1rem;
  padding: 1rem;
  background-color: #f5f5f5;
  border-radius: 4px;
}
```

### 7. Test the dapp

Run the development server if it's not already running:

```bash
npm run dev
```

Open your browser and navigate to the localhost URL shown in the terminal.

Test the dapp by:

1. Clicking **Connect MetaMask** to connect your wallet.
2. Entering token addresses (or using the defaults).
3. Entering an amount to swap.
4. Clicking **Get Quote** to see the estimated output.
5. Clicking **Execute Swap** to perform the token swap.

:::caution Network requirements
This tutorial uses Ethereum mainnet (Chain ID: 1).
Ensure you're connected to the correct network in MetaMask and have sufficient ETH for gas fees.

For testing purposes, you can modify the `chainId` variable to use a testnet, but you'll need
testnet tokens and to verify that 1inch supports that network.
:::

## Next steps

This tutorial provides a basic integration with 1inch.
You can enhance the dapp by:

- Adding a token selection UI with a list of popular tokens.
- Displaying estimated gas fees before swapping.
- Implementing slippage tolerance controls.
- Adding transaction history tracking.
- Supporting multiple networks (Polygon, BSC, Arbitrum, etc.).
- Handling ERC-20 token approvals properly before swapping.
- Adding error handling for insufficient balance or allowance.

## Additional resources

- [1inch Developer Portal](https://portal.1inch.dev/)
- [1inch API Documentation](https://docs.1inch.io/)
- [MetaMask Provider API](../reference/provider-api.md)
- [Ethers.js Documentation](https://docs.ethers.org/)
