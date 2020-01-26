#!/bin/bash
set -e

out_cp () {
   echo "$(tput bold)$(tput setaf 4) COPY: $@ $(tput sgr 0)"
}

out_cp "Copying to bucket"
gsutil -q -m cp -r config config.env docker-compose-* *-startup.sh *-entrypoint.sh gs://spacemesh/sm/ &
gsutil -q cp .gcp.env gs://spacemesh/sm/.env &

wait

out_cp "Done!"