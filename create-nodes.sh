#!/bin/bash
set -e

out_nodes () {
   echo "$(tput bold)$(tput setaf 3) NODES: $@ $(tput sgr 0)"
}

if (( $(gcloud compute instances list --filter="name=(nodes)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
   out_nodes "Deleting old VM"
   gcloud --quiet compute instances delete nodes --zone us-east1-b
fi

out_nodes "Creating new VM"
gcloud compute instances create nodes \
   --zone us-east1-b \
   --image cos-stable-78-12499-89-0 \
   --image-project cos-cloud \
   --machine-type=n1-standard-32 \
   --boot-disk-type=pd-ssd \
   --boot-disk-size=1024GB \
   --address 34.73.217.215 \
   --tags nodes \
   --metadata startup-script-url=gs://spacemesh/sm/nodes-startup.sh,nodes=50

# out_nodes "Waiting for response"
# until $(curl --output /dev/null --silent --fail -d '' http://nodes.unruly.io:9999/v1/genesis); do
#   sleep 1
# done

out_nodes "Waiting for POET started"
until [[ $(curl --silent poet.unruly.io:8080/v1/info) == *"openRoundId"* ]]; do
  sleep 1
done

out_nodes "Ready!"