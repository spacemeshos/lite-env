#!/bin/sh
# set -e

apk -q add wget

if [ "$BOOTSTRAP_NODE" = true ] ; then
  echo "- BOOTSTRAP MODE -"
  export GENESIS=$(date -d "@$(($(date +%s) + $GENESIS_SEC_DELAY))" --utc +%Y-%m-%dT%H:%M:%S+00:00)
else
  export GENESIS=$(wget -qO- --retry-on-http-error=500,503 --post-data '' -w 1 --retry-connrefused bs_node:9090/v1/genesis | awk 'BEGIN { FS="\""; RS="," }; { if ($2 == "value") {print $4} }')
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
    --poet-server "${POET_URL}:50002" \
    --metrics-port 2020 \
    $MINER &

bg_pid=$!

if $BOOTSTRAP_NODE ; then
  wget -qO- --tries=0 --retry-connrefused --post-data '{ "gatewayAddresses": ["'${BS_NODE_URL}':9091"] }' ${POET_URL}:8080/v1/start
  echo "- POET STARTED -"
else
  echo "- MINING -"
fi

wait $bg_pid
exec "$@"