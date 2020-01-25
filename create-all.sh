#!/bin/bash
set -e

./cp-all.sh

./delete-all.sh

(./create-poet.sh && ./create-nodes.sh) &
./create-metrics.sh &

wait
echo "  - DONE! -"