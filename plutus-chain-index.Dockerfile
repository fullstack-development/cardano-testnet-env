FROM nixos/nix

RUN nix-channel --update

RUN echo 'substituters = https://hydra.iohk.io https://iohk.cachix.org https://cache.nixos.org/' >> /etc/nix/nix.conf && \
    echo 'trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=' >> /etc/nix/nix.conf

WORKDIR /workdir

RUN git clone https://github.com/input-output-hk/plutus-apps.git && \
    cd plutus-apps && \
    git checkout 3377926c9b0818e2107934f8f1bd936440fe0bb4

RUN cd plutus-apps && \
    nix build --extra-experimental-features nix-command -f default.nix plutus-apps.haskell.packages.plutus-chain-index.components.exes.plutus-chain-index

RUN mkdir /ipc /data

ENV CARDANO_NODE_SOCKET_PATH=/ipc/node.socket
ENV DB_PATH=/data
ENV NETWORK_ID=1097911063
ENV ADDITIONAL_PARAMS=

EXPOSE 9083

CMD (while [ ! -S "$CARDANO_NODE_SOCKET_PATH" ]; do echo "waiting for socket..."; sleep 5 ; done) && \
  ./plutus-apps/result/bin/plutus-chain-index \
    --socket-path ${CARDANO_NODE_SOCKET_PATH} \
    --db-path ${DB_PATH}/chain-index.db \
    --network-id ${NETWORK_ID} \
    ${ADDITIONAL_PARAMS} \
    start-index
