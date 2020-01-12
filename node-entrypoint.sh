#!/bin/sh
# set -e

apk -q add wget

if [ "$BOOTSTRAP_NODE" = true ] ; then
  echo "- BOOTSTRAP NODE -"
  echo "- NUM_NODES=$NUM_NODES -"
  export GENESIS=$(date -d "@$(($(date +%s) + $GENESIS_SEC_DELAY))" --utc +%Y-%m-%dT%H:%M:%S+00:00)
  echo "- GENESIS: $GENESIS -"
else
  echo "- MINER NODE -"
  export GENESIS=$(wget -qO- --retry-on-http-error=500,503 --post-data '' -w 1 --retry-connrefused bs_node:9090/v1/genesis | awk 'BEGIN { FS="\""; RS="," }; { if ($2 == "value") {print $4} }')
  export MINER="\
    --bootstrap \
    --bootnodes spacemesh://`ls /root/spacemesh/pk/`@`getent hosts bs_node | awk '{ print $1 }'`:7513"
fi

set -o xtrace

# printf '[logging]\nhare = "debug"' > config.toml

/bin/go-spacemesh \
    --test-mode \
    --metrics \
    --grpc-server \
    --json-server \
    --randcon $RANDCON \
    --hare-committee-size $HARE_COMMITTEE_SIZE \
    --hare-max-adversaries $HARE_MAX_ADVERSARIES \
    --hare-round-duration-sec $HARE_ROUND_DURATION_SEC \
    --hare-exp-leaders $HARE_EXP_LEADERS \
    --layer-duration-sec $LAYER_DURATION_SEC \
    --layer-average-size $LAYER_AVERAGE_SIZE \
    --hare-wakeup-delta $HARE_WAKEUP_DELTA \
    --layers-per-epoch $LAYERS_PER_EPOCH \
    --coinbase $COINBASE \
    --eligibility-confidence-param $ELIGIBILITY_CONFIDENCE_PARAM \
    --eligibility-epoch-offset $ELIGIBILITY_EPOCH_OFFSET \
    --genesis-active-size $NUM_NODES \
    --genesis-time "$GENESIS" \
    --poet-server "${POET_URL}:50002" \
    --metrics-port 2020 \
    --start-mining \
    $MINER &

set +o xtrace

bg_pid=$!

if [ "$BOOTSTRAP_NODE" = true ] ; then
  wget -qO- --tries=0 --retry-connrefused --post-data '{ "gatewayAddresses": ["'${BS_NODE_URL}':9091"] }' ${POET_URL}:8080/v1/start
  echo "- POET STARTED -"
fi

wait $bg_pid
exec "$@"