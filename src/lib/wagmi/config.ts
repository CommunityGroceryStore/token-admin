import { http, createConfig } from '@wagmi/vue'
import {
  mainnet,
  sepolia
} from '@wagmi/vue/chains'
import { defineChain } from 'viem'

declare module '@wagmi/vue' {
  interface Register {
    config: typeof config
  }
}

export const localhost = defineChain({
  id: 539,
  name: 'Localhost',
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: { http: ['http://127.0.0.1:7545'] },
  },
})

export const config = import.meta.env.VITE_EVM_NETWORK === 'mainnet'
  ? createConfig({
    chains: [ mainnet ],
    transports: {
      [mainnet.id]: http()
    }
  }) : import.meta.env.VITE_EVM_NETWORK === 'sepolia'
  ? createConfig({
    chains: [ sepolia ],
    transports: {
      [sepolia.id]: http()
    }
  }) : createConfig({
    chains: [ localhost ],
    transports: {
      [localhost.id]: http()
    }
  })

export const networks = import.meta.env.VITE_EVM_NETWORK === 'mainnet'
  ? [ mainnet ]
  : import.meta.env.VITE_EVM_NETWORK === 'sepolia'
    ? [ sepolia ]
    : [ localhost ]
