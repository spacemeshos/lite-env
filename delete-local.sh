#!/bin/bash
set -e

docker-compose -f docker-compose-poet.yml down -v &
docker-compose -f docker-compose-metrics.yml down -v &
docker-compose -f docker-compose-nodes.yml down -v &

wait

docker volume rm sm_es_data
