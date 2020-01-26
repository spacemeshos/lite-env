toolbox /google-cloud-sdk/bin/gsutil -m cp -r gs://spacemesh/sm/* .
cd /var/lib/toolbox/*/
export $(grep GENESIS_ACTIVE_SIZE config.env)
docker rm $(docker ps -a -q) ; docker volume prune -f ; docker network prune -f
docker pull spacemeshos/go-spacemesh:develop
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:$PWD -w $PWD docker/compose -f docker-compose-nodes.yml up -d --scale node=$GENESIS_ACTIVE_SIZE
