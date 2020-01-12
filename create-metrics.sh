#!/bin/bash
set -e

out_metrics () {
   echo "$(tput bold)$(tput setaf 5) METRICS: $@ $(tput sgr 0)"
}

. .gcp.env
. defaults.env

if (( $(gcloud compute instances list --filter="name=(metrics)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
   out_metrics "Deleting old VM"
   gcloud --quiet compute instances delete metrics --zone us-east1-c
fi

out_metrics "Creating new VM"
gcloud compute instances create metrics \
   --zone us-east1-c \
   --image-family cos-stable \
   --image-project cos-cloud \
   --machine-type=e2-standard-8 \
   --boot-disk-type=pd-ssd \
   --boot-disk-size=100GB \
   --address 34.74.67.41 \
   --tags metrics \
   --metadata startup-script-url=gs://spacemesh/sm/metrics-startup.sh

out_metrics "Waiting for response"
until $(gcloud compute ssh poet --command "curl --output /dev/null --silent --fail ${FLUENT_BIT_URL}:9200"); do
  sleep 1
done

out_metrics "Waiting for Elasticsearch yellow status"
gcloud compute ssh poet --command "curl  --output /dev/null --silent ${FLUENT_BIT_URL}:9200/_cluster/health?wait_for_status=yellow&timeout=120s"

out_metrics "Ready!"