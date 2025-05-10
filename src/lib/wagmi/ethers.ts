import {
  FallbackProvider,
  JsonRpcProvider
} from 'ethers'
import type { Transport } from 'viem'
import {
  type Config,
  useClient,
  useChainId
} from '@wagmi/vue'

export function useEthersProvider() {
  const chainId = useChainId()
  const client = useClient<Config>({ chainId })
  if (!client.value) {
    return null
  }
  const { chain, transport } = client.value
  const network = {
    chainId: chain.id,
    name: chain.name,
    ensAddress: chain.contracts?.ensRegistry?.address,
  }
  if (transport.type === 'fallback') {
    const providers = (transport.transports as ReturnType<Transport>[]).map(
      ({ value }) => new JsonRpcProvider(value?.url, network),
    )
    if (providers.length === 1) return providers[0]
    return new FallbackProvider(providers)
  }
  return new JsonRpcProvider(transport.url, network)
}
