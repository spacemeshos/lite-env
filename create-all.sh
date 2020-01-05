#!/bin/bash
set -e

gsutil -q -m cp -r config defaults.env docker-compose-* *-startup.sh *-entrypoint.sh gs://spacemesh/sm/
gsutil -q cp .gcp.env gs://spacemesh/sm/.env

./delete-all.sh

./create-poet.sh &
./create-metrics.sh &

wait

./create-nodes.sh
