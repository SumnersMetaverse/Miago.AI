---
description: Connect to OKX Wallet using EIP-6963 multi-wallet detection.
toc_max_heading_level: 4
keywords: [okx, wallet, extension, API, EIP-6963]
---

# Connect to OKX Wallet

You can connect your dapp to OKX Wallet using the [EIP-6963](../concepts/wallet-interoperability.md)
multi-wallet detection mechanism.
EIP-6963 allows your dapp to detect and connect to multiple wallet providers, including OKX Wallet,
without conflicts.

:::info Why EIP-6963?
[EIP-6963](https://eips.ethereum.org/EIPS/eip-6963) introduces an alternative wallet detection
mechanism to the `window.ethereum` injected provider, enabling dapps to support
[wallet interoperability](../concepts/wallet-interoperability.md) by discovering multiple injected
wallet providers in a user's browser.
:::

## Prerequisites

- [Node.js](https://nodejs.org/) version 18+
- [OKX Wallet browser extension](https://www.okx.com/web3) installed
- Basic knowledge of TypeScript and Ethereum wallet integration

## OKX Wallet RDNS identifier

OKX Wallet uses the RDNS identifier `com.okex.wallet` for EIP-6963 provider discovery.
You can use this identifier to specifically connect to OKX Wallet in your dapp.

## TypeScript interfaces

Before implementing wallet connections, you'll need the EIP-6963 TypeScript interfaces.
Add these to your project (e.g., in a `types.ts` or `vite-env.d.ts` file):

```typescript
// EIP-6963 Provider Info
interface EIP6963ProviderInfo {
  rdns: string
  uuid: string
  name: string
  icon: string
}

// EIP-6963 Provider Detail
interface EIP6963ProviderDetail {
  info: EIP6963ProviderInfo
  provider: EIP1193Provider
}

// EIP-6963 Announce Provider Event
type EIP6963AnnounceProviderEvent = {
  detail: {
    info: EIP6963ProviderInfo
    provider: Readonly<EIP1193Provider>
  }
}

// EIP-1193 Provider
interface EIP1193Provider {
  isStatus?: boolean
  host?: string
  path?: string
  sendAsync?: (
    request: { method: string; params?: Array<unknown> },
    callback: (error: Error | null, response: unknown) => void
  ) => void
  send?: (
    request: { method: string; params?: Array<unknown> },
    callback: (error: Error | null, response: unknown) => void
  ) => void
  request: (request: { method: string; params?: Array<unknown> }) => Promise<unknown>
  on?: (event: string, callback: (...args: any[]) => void) => void
  removeListener?: (event: string, callback: (...args: any[]) => void) => void
}
```

## Connect to OKX Wallet

### Option 1: Connect to any EIP-6963 wallet (recommended)

The recommended approach is to support all EIP-6963 compatible wallets and let users choose their
preferred wallet:

```typescript
// Declare the custom event type
declare global {
  interface WindowEventMap {
    'eip6963:announceProvider': CustomEvent
  }
}

// Store discovered providers
const providers: Map<string, EIP6963ProviderDetail> = new Map()

// Listen for wallet provider announcements
window.addEventListener('eip6963:announceProvider', (event: EIP6963AnnounceProviderEvent) => {
  providers.set(event.detail.info.uuid, event.detail)

  // Display wallet option to user
  displayWalletOption(event.detail)
})

// Request wallet providers to announce themselves
window.dispatchEvent(new Event('eip6963:requestProvider'))

// Connect to selected wallet
async function connectToWallet(provider: EIP1193Provider) {
  try {
    const accounts = await provider.request({
      method: 'eth_requestAccounts',
    })
    console.log('Connected accounts:', accounts)
    return accounts
  } catch (error) {
    console.error('Failed to connect:', error)
  }
}
```

### Option 2: Connect specifically to OKX Wallet

If you want to connect specifically to OKX Wallet, filter for its RDNS identifier:

```typescript
// Wait for OKX Wallet to be available
function waitForOKXWallet(): Promise<EIP1193Provider> {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      reject(new Error('OKX Wallet not found'))
    }, 3000)

    window.addEventListener('eip6963:announceProvider', (event: EIP6963AnnounceProviderEvent) => {
      if (event.detail.info.rdns === 'com.okex.wallet') {
        clearTimeout(timeout)
        resolve(event.detail.provider)
      }
    })

    // Request providers
    window.dispatchEvent(new Event('eip6963:requestProvider'))
  })
}

// Connect to OKX Wallet
async function connectToOKX() {
  try {
    const okxProvider = await waitForOKXWallet()
    const accounts = await okxProvider.request({
      method: 'eth_requestAccounts',
    })
    console.log('Connected to OKX Wallet:', accounts)
    return { provider: okxProvider, accounts }
  } catch (error) {
    console.error('Failed to connect to OKX Wallet:', error)
    throw error
  }
}
```

### Option 3: Using third-party libraries

You can also connect to OKX Wallet using third-party libraries that support EIP-6963:

#### Using Wagmi

```typescript
import { createConfig, http } from 'wagmi'
import { mainnet } from 'wagmi/chains'
import { injected } from 'wagmi/connectors'

const config = createConfig({
  chains: [mainnet],
  connectors: [
    injected({
      target: {
        id: 'okx',
        name: 'OKX Wallet',
        provider: window => {
          // Wagmi will automatically detect OKX via EIP-6963
          return window?.okxwallet
        },
      },
    }),
  ],
  transports: {
    [mainnet.id]: http(),
  },
})
```

#### Using MIPD Store

```typescript
import { createStore } from 'mipd'

const store = createStore()

// Get OKX Wallet provider
const okxProvider = store.getProviders().find(provider => provider.info.rdns === 'com.okex.wallet')

if (okxProvider) {
  await okxProvider.provider.request({ method: 'eth_requestAccounts' })
}
```

## Complete React example

Here's a complete React component that connects to OKX Wallet:

```tsx
import { useState, useEffect } from 'react'

interface WalletState {
  accounts: string[]
  chainId: string
  isConnected: boolean
}

export function OKXWalletConnect() {
  const [wallet, setWallet] = useState<WalletState>({
    accounts: [],
    chainId: '',
    isConnected: false,
  })
  const [provider, setProvider] = useState<EIP1193Provider | null>(null)

  useEffect(() => {
    // Listen for OKX Wallet
    const handleAnnouncement = (event: EIP6963AnnounceProviderEvent) => {
      if (event.detail.info.rdns === 'com.okex.wallet') {
        setProvider(event.detail.provider)
      }
    }

    window.addEventListener('eip6963:announceProvider', handleAnnouncement)
    window.dispatchEvent(new Event('eip6963:requestProvider'))

    return () => {
      window.removeEventListener('eip6963:announceProvider', handleAnnouncement)
    }
  }, [])

  const connectWallet = async () => {
    if (!provider) {
      alert('OKX Wallet not detected. Please install it from okx.com/web3')
      return
    }

    try {
      const accounts = (await provider.request({
        method: 'eth_requestAccounts',
      })) as string[]

      const chainId = (await provider.request({
        method: 'eth_chainId',
      })) as string

      setWallet({
        accounts,
        chainId,
        isConnected: true,
      })
    } catch (error) {
      console.error('Failed to connect:', error)
    }
  }

  const disconnectWallet = () => {
    setWallet({
      accounts: [],
      chainId: '',
      isConnected: false,
    })
  }

  return (
    <div>
      {!wallet.isConnected ? (
        <button onClick={connectWallet} disabled={!provider}>
          {provider ? 'Connect OKX Wallet' : 'OKX Wallet Not Detected'}
        </button>
      ) : (
        <div>
          <p>Connected: {wallet.accounts[0]}</p>
          <p>Chain ID: {wallet.chainId}</p>
          <button onClick={disconnectWallet}>Disconnect</button>
        </div>
      )}
    </div>
  )
}
```

## Listen to wallet events

Once connected, you can listen to OKX Wallet events:

```typescript
// Listen for account changes
provider.on('accountsChanged', (accounts: string[]) => {
  console.log('Accounts changed:', accounts)
  // Update your UI with new accounts
})

// Listen for chain changes
provider.on('chainChanged', (chainId: string) => {
  console.log('Chain changed:', chainId)
  // Reload the page or update state
  window.location.reload()
})

// Listen for disconnection
provider.on('disconnect', (error: any) => {
  console.log('Disconnected:', error)
  // Update your UI to show disconnected state
})
```

## Best practices

1. **Support multiple wallets**: Rather than only supporting OKX Wallet, implement EIP-6963 to support all compatible wallets and let users choose.

2. **Handle wallet not installed**: Always check if the wallet is available and provide clear instructions if it's not.

3. **Listen to events**: Subscribe to account and chain change events to keep your dapp in sync.

4. **Error handling**: Implement proper error handling for connection failures and user rejections.

5. **Persist wallet selection**: Save the user's wallet preference to localStorage for a better UX.

## Related resources

- [EIP-6963 specification](https://eips.ethereum.org/EIPS/eip-6963)
- [Wallet interoperability concepts](../concepts/wallet-interoperability.md)
- [Connect to MetaMask extension](connect-extension.md)
- [OKX Wallet documentation](https://www.okx.com/web3/build/docs/sdks/chains/ethereum/provider)

## See also

- [Detect a user's network](manage-networks/detect-network.md)
- [Access a user's accounts](access-accounts.md)
- [Send transactions](send-transactions/index.md)
