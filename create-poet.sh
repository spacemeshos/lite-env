#!/bin/bash
set -e

out_poet () {
   echo "$(tput bold)$(tput setaf 6) POET: $@ $(tput sgr 0)"
}

if (( $(gcloud compute instances list --filter="name=(poet)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
   out_poet "Deleting old VM"
   gcloud --quiet compute instances delete poet --zone us-east1-b
fi

out_poet "Creating new VM"
(export NUM_LEAVES=${1:-19} && \
out_poet "NUM_LEAVES=$NUM_LEAVES" && \
gcloud compute instances create-with-container poet \
   --zone us-east1-b \
   --container-image spacemeshos/poet:develop \
   --container-arg="--rpclisten" \
   --container-arg="0.0.0.0:50002" \
   --container-arg="--restlisten" \
   --container-arg="0.0.0.0:8080" \
   --container-arg="--n" \
   --container-arg="$NUM_LEAVES" \
   --container-arg="--jsonlog" \
   --machine-type=e2-highmem-4 \
   --boot-disk-type=pd-standard \
   --boot-disk-size=1TB \
   --address 35.231.54.161 \
   --tags poet)

out_poet "Waiting for response"
until [[ $(curl --silent poet.unruly.io:8080/v1/info) == *"service not started"* ]]; do
  sleep 1
done

out_poet "Ready!"