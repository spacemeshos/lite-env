toolbox /google-cloud-sdk/bin/gsutil -m cp -r gs://spacemesh/sm/* .
cd /var/lib/toolbox/*/
export $(grep GENESIS_ACTIVE_SIZE config.env)
export EXT_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
echo "EXT_IP: ${EXT_IP}"
docker rm $(docker ps -a -q) ; docker volume prune -f ; docker network prune -f
docker pull spacemeshos/go-spacemesh:v0.1.3
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:$PWD -w $PWD -e "EXT_IP=${EXT_IP}" docker/compose -f docker-compose-nodes.yml up -d --scale node=$GENESIS_ACTIVE_SIZE
