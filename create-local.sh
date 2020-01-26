#!/bin/bash
set -e

docker network create sm_default
(export NUM_LEAVES=${2:-19} && echo "NUM_LEAVES=$NUM_LEAVES" && docker-compose -f docker-compose-poet.yml up) &
docker-compose -f docker-compose-metrics.yml up &
(export GENESIS_ACTIVE_SIZE=${1:-30} && echo "GENESIS_ACTIVE_SIZE=$GENESIS_ACTIVE_SIZE" && docker-compose -f docker-compose-nodes.yml up --scale node=$GENESIS_ACTIVE_SIZE) &
