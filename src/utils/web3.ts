import { BrowserProvider, JsonRpcSigner } from 'ethers'
import { type UseConnectorClientReturnType } from '@wagmi/vue'

export function getSigner(client: UseConnectorClientReturnType) {
  if (!client.data.value) {
    return null
  }
  const { account, chain, transport } = client.data.value
  const network = {
    chainId: chain.id,
    name: chain.name,
    ensAddress: chain.contracts?.ensRegistry?.address,
  }
  const provider = new BrowserProvider(transport, network)

  return new JsonRpcSigner(provider, account.address)
}
