#!/bin/sh
# set -e

apk -q add --update wget curl jq iptables gettext

export NODES_IP=$(getent hosts ${BS_NODE_URL} | awk '{ print $1 }')
export EXT_PORT=7513
export COINBASE="0x1234"

if ! $BOOTSTRAP ; then
  echo "- BOOTSTRAP NODE -"
  echo "- NUM_NODES=$NUM_NODES -"
  wget -qO- --tries=0 --retry-connrefused ${POET_URL}:8080/v1/info
  export GENESIS_TIME=$(date -d "@$(($(date +%s) + $GENESIS_SEC_DELAY))" --utc +%Y-%m-%dT%H:%M:%S+00:00)
  echo "- GENESIS_TIME: $GENESIS_TIME -"
  envsubst < /root/config/config.toml.tmpl > ./config.toml
else
  echo "- MINER NODE -"
  export EXT_PORT=$(curl --unix-socket /var/run/docker.sock http://localhost/containers/${HOSTNAME}/json | jq -r '.NetworkSettings.Ports."7513/tcp"[0].HostPort')
  iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 7513 -j REDIRECT --to-port ${EXT_PORT}
  iptables -t nat -A PREROUTING -i eth0 -p udp --dport 7513 -j REDIRECT --to-port ${EXT_PORT}
  iptables-save
  until [ -f /root/config/config.toml ]; do sleep 1; done
  cp  /root/config/config.toml ./config.toml
fi

set -o xtrace

/bin/go-spacemesh \
    --test-mode \
    --grpc-server \
    --json-server \
    --metrics \
    --start-mining \
    --coinbase $COINBASE \
    --tcp-port $EXT_PORT &

set +o xtrace

bg_pid=$!

until [ -d /root/spacemesh/nodes ]; do sleep 1; done
export P2P="\"spacemesh://`ls /root/spacemesh/nodes`@${NODES_IP}:${EXT_PORT}\""
echo "P2P: $P2P"

if ! $BOOTSTRAP ; then
  export BOOTSTRAP=true
  envsubst < /root/config/config.toml.tmpl > /root/config/config.toml
  wget -qO- --tries=0 --retry-connrefused --post-data '{ "gatewayAddresses": ["'${BS_NODE_URL}':9091"] }' ${POET_URL}:8080/v1/start
  echo "- POET STARTED -"
fi

wait $bg_pid
exec "$@"