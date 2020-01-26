#!/bin/bash
set -e

docker network create sm_default
(export NUM_LEAVES=${2:-19} && echo "NUM_LEAVES=$NUM_LEAVES" && docker-compose -f docker-compose-poet.yml up) &
docker-compose -f docker-compose-metrics.yml up &
(export NUM_NODES=${1:-30} && echo "NUM_NODES=$NUM_NODES" && docker-compose -f docker-compose-nodes.yml up --scale node=$NUM_NODES) &
