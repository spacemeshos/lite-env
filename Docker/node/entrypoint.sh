#!/bin/sh
# set -e

if [ "$BOOTSTRAP_NODE" = true ] ; then
  echo "- BOOTSTRAP MODE -"
  export GENESIS=$(date -d "@$(($(date +%s) + $GENESIS_SEC_DELAY))" --utc +%Y-%m-%dT%H:%M:%S+00:00)
else
  export GENESIS=$(wget -qO- --retry-on-http-error=500,503 --post-data ''  http://bs_node:9090/v1/genesis | awk 'BEGIN { FS="\""; RS="," }; { if ($2 == "value") {print $4} }')
  export GENESIS=$(echo "$GENESIS" | awk -F"[ ]+" '{print $1"T"$2"+00:00"}')
  export MINER="\
    --start-mining \
    --bootstrap \
    --bootnodes spacemesh://`ls /root/spacemesh/pk/`@`getent hosts bs_node | awk '{ print $1 }'`:7513"
fi

echo "GENESIS: $GENESIS"
echo "MINER: $MINER"

/bin/go-spacemesh \
    --test-mode \
    --metrics \
    --pprof-server \
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
    --genesis-active-size $GENESIS_ACTIVE_SIZE \
    --genesis-time "$GENESIS" \
    --poet-server "poet:$POET_RPC_PORT" \
    --metrics-port $METRICS_PORT \
    $MINER &

bg_pid=$!

if $BOOTSTRAP_NODE ; then
  wget -qO- --post-data '{ "nodeAddress": "bs_node:9091" }' http://poet:$POET_REST_PORT/v1/start
fi

wait $bg_pid
exec "$@"