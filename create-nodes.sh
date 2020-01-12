#!/bin/bash
set -e

out_nodes () {
   echo "$(tput bold)$(tput setaf 3) NODES: $@ $(tput sgr 0)"
}

. .gcp.env
. defaults.env
out_nodes "NUM_NODES=$NUM_NODES"

if (( $(gcloud compute instances list --filter="name=(nodes)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
   out_nodes "Deleting old VM"
   gcloud --quiet compute instances delete nodes --zone us-east1-c
fi

out_nodes "Creating new VM"
gcloud compute instances create nodes \
   --zone us-east1-c \
   --image-family cos-stable \
   --image-project cos-cloud \
   --machine-type=n1-highcpu-96 \
   --boot-disk-type=pd-ssd \
   --boot-disk-size=256GB \
   --address 34.73.217.215 \
   --tags nodes \
   --metadata startup-script-url=gs://spacemesh/sm/nodes-startup.sh

out_nodes "Waiting for POET started"
until [[ $(gcloud compute ssh poet --command "curl --silent ${POET_URL}:8080/v1/info") == *"openRoundId"* ]]; do
  sleep 1
done

out_nodes "Ready!"