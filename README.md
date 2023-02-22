# Dockerized cardano testnet environment
This repo contains docker infrastructure necessary to set up and run
[`cardano-node`](https://hub.docker.com/r/inputoutput/cardano-node),
[`cardano-wallet`](https://hub.docker.com/r/inputoutput/cardano-wallet) and
[`plutus-chain-index`](https://github.com/input-output-hk/plutus-apps/tree/main/plutus-chain-index).

## Before running
Download preprod configs to `./preprod-configs` directory

## Running
```sh
docker-compose up -d
```

## Using
`cardano-wallet` and `plutus-chain-index` are available on ports `8090` and `9083` respectively. `cardano-node`, on the other hand is only available via socket, in order to access it remotely you can use `socat`. Run this command on your local machine:
```
socat UNIX-LISTEN:${CARDANO_NODE_SOCKET_PATH},fork,reuseaddr,unlink-early, TCP:${HOST_IP_ADDR}:1234
```

### Wrapping socat in systemd service
For developers convenience it may make sense to wrap it into the custom service for `systemd`.

Write this to `~/.config/systemd/user/some-concrete-cardano-node.service`:
```systemd
[Unit]
Description=Some concrete cardano testnet node tunnel

[Service]
Type=simple
SyslogIdentifier=some-concrete-cardano-node-tunnel
Restart=always
RestartSec=5
KillSignal=SIGINT
LimitNOFILE=32768
ExecStart=socat UNIX-LISTEN:${CARDANO_NODE_SOCKET_PATH},fork,reuseaddr,unlink-early, TCP:${HOST_IP_ADDR}:1234
Environment="CARDANO_NODE_SOCKET_PATH=/tmp/node.socket"
Environment="HOST_IP_ADDR=<IP HERE>"

[Install]
WantedBy=default.target
```

Make sure you specify correct `CARDANO_NODE_SOCKET_PATH` and `HOST_IP_ADDR`.

Start and enable the service:
```sh
systemctl --user daemon-reload
systemctl --user enable some-concrete-cardano-node
systemctl --user start some-concrete-cardano-node
```

Check if it's up and running:
```sh
systemctl --user status some-concrete-cardano-node
```

Now you don't need to start `socat` each time after reboot.

### "Connection lost with the node. Couldn't connect to node (x999). Retrying in a bit..."

`cardano-wallet` may spam such warnings in its output. There is no cause for panic, this happens during normal operation due to a bug within cardano-wallet itself: [Rework the "Local Tx Submission" node client. #3487](https://github.com/input-output-hk/cardano-wallet/pull/3487).


### NOTE

If you want to deploy testnet on the same machine with PAB, you can use node socket strightly without `socat`. `production-env` branch contains the version without socat.
