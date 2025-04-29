import { http, createConfig } from '@wagmi/vue'
import { mainnet, sepolia } from '@wagmi/vue/chains'

declare module '@wagmi/vue' {
    interface Register {
      config: typeof config
    }
  }

export const config = createConfig({
  chains: [mainnet, sepolia],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
  },
})

export const networks = [mainnet, sepolia]