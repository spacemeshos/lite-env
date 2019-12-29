#!/bin/sh
set -e

/bin/poet \
    --rpclisten 0.0.0.0:$POET_RPC_PORT \
    --restlisten 0.0.0.0:$POET_REST_PORT \
    --n $NUM_LEAVES

exec "$@"