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
  /usr/src/app/artifacts/contract-bytecode.ts \
  /usr/src/app/artifacts/wagmi-generated.ts \
  /usr/src/app/src/assets/contract-artifacts/
RUN npm run build

FROM node:22-slim AS deploy
WORKDIR /usr/src/app
RUN apt-get -y update; apt-get -y install curl unzip rclone
COPY --from=build --chmod=555 /usr/src/app/dist /usr/src/app/dist
