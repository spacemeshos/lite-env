#!/bin/bash
set -e

out_delete () {
   echo "$(tput bold)$(tput setaf 1) DELETE: $@ $(tput sgr 0)"
}

if (( $(gcloud compute instances list --filter="name=(poet)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
  out_delete "poet"
  gcloud --quiet compute instances delete poet --zone us-east1-c &
fi

if (( $(gcloud compute instances list --filter="name=(metrics)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
  out_delete "metrics"
  gcloud --quiet compute instances delete metrics --zone us-east1-c &
fi

if (( $(gcloud compute instances list --filter="name=(nodes)" 2> /dev/null | wc -l | awk '{print $1}') > 0 )); then
  out_delete "nodes"
  gcloud --quiet compute instances delete nodes --zone us-east1-c &
fi

wait

out_delete "Done!"
