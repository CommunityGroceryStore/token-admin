# CommunityGroceryStore Token Admin

## Install
```bash
npm install
```
### Contract Type Dependencies
From the
[communitygrocerystore/contracts](https://github.com/communitygrocerystore/contracts)
repository:

1) Generate ABI and bytecode artifacts:
```bash
npm install
npx hardhat compile
npx wagmi generate
npx tsx scripts/copy-contract-bytecode.ts
```
2) Copy to assets folder `token-admin/src/contract-artifacts`:
  - `contracts/artifacts/contract-bytecode.ts`
  - `contracts/artifacts/wagmi-generates.ts`

## Run Local Dev
### 1) Run local Hardhat network
From the
[communitygrocerystore/contracts](https://github.com/communitygrocerystore/contracts)
repository:
```bash
npx hardhat node --port 7545
```

### 2) Start local hot-reload dev server
```bash
npm run dev
```

## Build
```bash
npm run build
```
Serve the static build from the generated `dist` directory

## Build & Run with Docker
```bash
docker pull ghcr.io/communitygrocerystore/token-admin:[[tag]]
docker run --port 3000:3000 ghcr.io/communitygrocerystore/token-admin
```
