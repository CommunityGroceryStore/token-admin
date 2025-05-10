FROM ghcr.io/communitygrocerystore/contracts:latest AS contracts

FROM node:22-alpine AS build
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH}
WORKDIR /usr/src/app
COPY package*.json .
RUN apk add --no-cache python3 py3-pip make g++
RUN npm install
COPY . .
COPY --from=contracts \
  /usr/src/app/artifacts/contracts/Token.sol/CGSToken.json \
  /usr/src/app/artifacts/contracts/Presale.sol/CGSTokenPresale.json \
  /usr/src/app/artifacts/contracts/Presale.sol/IVesting.json \
  /usr/src/app/artifacts/contracts/Vesting.sol/CGSVesting.json \
  ./src/assets/contract-artifacts/
RUN npm run build

FROM node:22-slim AS deploy
WORKDIR /usr/src/app
COPY --from=build --chmod=555 /usr/src/app/dist /usr/src/app/dist
RUN npm install -g serve
CMD ["serve", "/usr/src/app/dist", "-s", "-p", "3000"]
