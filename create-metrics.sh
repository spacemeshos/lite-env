#!/bin/bash
set -e

out_metrics () {
   echo "$(tput bold)$(tput setaf 5) METRICS: $@ $(tput sgr 0)"
}

if (( $(gcloud compute instances list --filter="name=(metrics)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
   out_metrics "Deleting old VM"
   gcloud --quiet compute instances delete metrics --zone us-east1-b
fi

out_metrics "Creating new VM"
gcloud compute instances create metrics \
   --zone us-east1-b \
   --image cos-stable-78-12499-89-0 \
   --image-project cos-cloud \
   --machine-type=n1-standard-8 \
   --boot-disk-type=pd-ssd \
   --boot-disk-size=256GB \
   --address 34.74.67.41 \
   --tags metrics \
   --hostname metrics.sm \
   --metadata startup-script-url=gs://spacemesh/sm/metrics-startup.sh

out_metrics "Waiting for response"
until $(curl --output /dev/null --silent --fail metrics.unruly.io:9200); do
  sleep 1
done

out_metrics "Waiting for Elasticsearch yellow status"
curl  --output /dev/null --silent "metrics.unruly.io:9200/_cluster/health?wait_for_status=yellow&timeout=120s"

out_metrics "Configuring Kibana"
until $(curl --output /dev/null --silent --fail metrics.unruly.io:5601/api/status); do
  sleep 1
done

curl -X POST "metrics.unruly.io:5601/api/saved_objects/_import" \
   -H "kbn-xsrf: true" \
   --form file=@config/kibana/sm.ndjson

curl -X POST "metrics.unruly.io:5601/api/kibana/settings" \
   -H "Content-Type: application/json" \
   -H "kbn-xsrf: true" \
   -d '{"changes":{"defaultIndex": "sm*"}}'

out_metrics "Ready!"