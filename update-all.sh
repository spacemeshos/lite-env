#!/bin/bash
set -e

./cp-all.sh

gcloud compute instances reset poet nodes metrics

echo "  - DONE! -"