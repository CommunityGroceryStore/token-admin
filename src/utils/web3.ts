import { BrowserProvider, JsonRpcSigner } from 'ethers'
import { type UseConnectorClientReturnType } from '@wagmi/vue'

export function getProvider(client: UseConnectorClientReturnType) {
  if (!client.data.value) {
    return null
  }
  const { chain, transport } = client.data.value
  const network = {
    chainId: chain.id,
    name: chain.name,
    ensAddress: chain.contracts?.ensRegistry?.address,
  }

  return new BrowserProvider(transport, network)
}

export function getSigner(client: UseConnectorClientReturnType) {
  if (!client.data.value) {
    return null
  }
  const { account } = client.data.value
  const provider = getProvider(client)
  if (!provider) {
    return null
  }

  return new JsonRpcSigner(provider, account.address)
}
