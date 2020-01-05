toolbox /google-cloud-sdk/bin/gsutil -m cp -r gs://spacemesh/sm/* .
export NUM_NODES=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nodes" -H "Metadata-Flavor: Google")
cd /var/lib/toolbox/*/
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:$PWD -w $PWD docker/compose -f docker-compose-nodes.yml up --scale node=$NUM_NODES
