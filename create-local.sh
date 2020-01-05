#!/bin/bash
set -e

docker network create sm_default
docker-compose -f docker-compose-poet.yml up &
docker-compose -f docker-compose-metrics.yml up &
docker-compose -f docker-compose-nodes.yml up --scale node=50 &
