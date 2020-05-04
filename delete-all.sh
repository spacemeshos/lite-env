#!/bin/bash
set -e

out_delete () {
   echo "$(tput bold)$(tput setaf 1) DELETE: $@ $(tput sgr 0)"
}

PROJECT=spacemesh-198810
ZONE=us-east1-c

VM=$(gcloud compute instances list --project $PROJECT --zones $ZONE --filter="name=(poet metrics nodes)" --format="value(name)" | xargs echo)
out_delete "$VM"
if [ -n "$VM" ]; then
  gcloud --quiet compute instances delete --project $PROJECT --zone $ZONE $VM
fi

out_delete "Done!"
