FROM ghcr.io/communitygrocerystore/contracts:latest AS contracts

FROM node:22-alpine AS build
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH}
WORKDIR /usr/src/app
COPY package*.json .
RUN apk add --no-cache python3 py3-pip make g++ curl unzip rclone
RUN npm install
COPY . .
COPY --from=contracts \
  /usr/src/app/artifacts/contract-bytecode.ts \
  /usr/src/app/artifacts/wagmi-generated.ts \
  /usr/src/app/src/assets/contract-artifacts/
