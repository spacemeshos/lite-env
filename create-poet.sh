#!/bin/bash
set -e

out_poet () {
  echo "$(tput bold)$(tput setaf 6) POET: $@ $(tput sgr 0)"
}

. .gcp.env
. config.env
out_poet "NUM_LEAVES=$NUM_LEAVES"

if (( $(gcloud compute instances list --filter="name=(poet)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
  out_poet "Deleting old VM"
  gcloud --quiet compute instances delete poet --zone us-east1-c
fi

out_poet "Creating new VM"
gcloud compute instances create-with-container poet \
  --zone us-east1-c \
  --container-image spacemeshos/poet:develop \
  --container-env-file config.env \
  --container-arg="--rpclisten=0.0.0.0:50002" \
  --container-arg="--restlisten=0.0.0.0:8080" \
  --container-arg="--jsonlog" \
  --container-arg="--n=$NUM_LEAVES" \
  --container-arg="--reset" \
  --machine-type=e2-standard-8 \
  --boot-disk-type=pd-standard \
  --boot-disk-size=1TB \
  --address 35.231.54.161 \
  --tags poet

out_poet "Waiting for response"
until [[ $(gcloud compute ssh poet --command "curl --silent ${POET_URL}:8080/v1/info") == *"service not started"* ]]; do
  sleep 1
done

out_poet "Ready!"
