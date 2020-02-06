#!/bin/sh
# set -e

apk -q add --update wget curl jq iptables gettext

export EXT_PORT=7513
export COINBASE="0x1234"

if ! $BOOTSTRAP ; then
  echo "- BOOTSTRAP NODE -"
  echo "- GENESIS_ACTIVE_SIZE=$GENESIS_ACTIVE_SIZE -"
  if [ $(getent hosts ${BS_NODE_URL} | awk '{ print $1 }')!= $EXT_IP ]; then
    echo "BS_NODE_URL doesn't resolve to ${EXT_IP}"
    exit 1
  fi
  export POET_IP=$(getent hosts ${POET_URL} | awk '{ print $1 }')
  wget -qO- --tries=0 --retry-connrefused ${POET_IP}:8080/v1/info
  export GENESIS_TIME=$(date -d "@$(($(date +%s) + $GENESIS_SEC_DELAY))" --utc +%Y-%m-%dT%H:%M:%S+00:00)
  echo "- GENESIS_TIME: $GENESIS_TIME -"
  envsubst < /root/config/config.toml.tmpl > ./config.toml
else
  echo "- MINER NODE -"
  export EXT_PORT=$(curl --unix-socket /var/run/docker.sock http://localhost/containers/${HOSTNAME}/json | jq -r '.NetworkSettings.Ports."7513/tcp"[0].HostPort')
  iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 7513 -j REDIRECT --to-port ${EXT_PORT}
  iptables -t nat -A PREROUTING -i eth0 -p udp --dport 7513 -j REDIRECT --to-port ${EXT_PORT}
  iptables-save
  wget -qO- --tries=0 --retry-connrefused ${BS_NODE_URL} -O ./config.toml
fi

set -o xtrace

/bin/go-spacemesh \
    --test-mode \
    --grpc-server \
    --json-server \
    --metrics-port 2020 \
    --metrics \
    --start-mining \
    --coinbase $COINBASE \
    --tcp-port $EXT_PORT &

set +o xtrace

bg_pid=$!

until [ -d /root/spacemesh/p2p/nodes ]; do sleep 1; done
export P2P="\"spacemesh://`ls /root/spacemesh/p2p/nodes`@${EXT_IP}:${EXT_PORT}\""
echo "P2P: $P2P"

if ! $BOOTSTRAP ; then
  export BOOTSTRAP=true
  envsubst < /root/config/config.toml.tmpl > /root/config/config.toml
  wget -qO- --tries=0 --retry-connrefused --post-data '{ "gatewayAddresses": ["'${EXT_IP}':9091"] }' ${POET_IP}:8080/v1/start
  echo "- POET STARTED -"
fi

wait $bg_pid
exec "$@"