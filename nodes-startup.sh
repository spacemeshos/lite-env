toolbox /google-cloud-sdk/bin/gsutil -m cp -r gs://spacemesh/sm/* .
cd /var/lib/toolbox/*/
export $(grep NUM_NODES defaults.env)
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:$PWD -w $PWD docker/compose -f docker-compose-nodes.yml up -d --scale node=$NUM_NODES
