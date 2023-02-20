# Dockerized cardano testnet environment
This repo contains docker infrastructure necessary to set up and run
[`cardano-node`](https://hub.docker.com/r/inputoutput/cardano-node),
[`cardano-wallet`](https://hub.docker.com/r/inputoutput/cardano-wallet) and
[`plutus-chain-index`](https://github.com/input-output-hk/plutus-apps/tree/main/plutus-chain-index).

## Before running
Download preprod configs to `./preprod-configs` directory

## Running
```sh
export NODE_IPC_VOLUME_SOURCE=path/to/volume/with/node/socket
docker-compose up -d
```

## Using
`cardano-wallet` and `plutus-chain-index` are available on ports `8090` and `9083` respectively.  `cardano-node` is available locally by socket file located in `${NODE_IPC_VOLUME_SOURCE}` directory.

### "Connection lost with the node. Couldn't connect to node (x999). Retrying in a bit..."

`cardano-wallet` may spam such warnings in its output. There is no cause for panic, this happens during normal operation due to a bug within cardano-wallet itself: [Rework the "Local Tx Submission" node client. #3487](https://github.com/input-output-hk/cardano-wallet/pull/3487).
