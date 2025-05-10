/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_EVM_NETWORK: 'localhost' | 'mainnet' | 'sepolia'
  readonly VITE_CGS_TOKEN_CONTRACT_ADDRESS: string
  readonly VITE_CGS_PRESALE_CONTRACT_ADDRESS: string
  readonly VITE_CGS_VESTING_CONTRACT_ADDRESS: string
}
