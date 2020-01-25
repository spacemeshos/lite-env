toolbox /google-cloud-sdk/bin/gsutil -m cp -r gs://spacemesh/sm/* .
cd /var/lib/toolbox/*/
docker rm $(docker ps -a -q) ; docker volume prune -f ; docker network prune -f
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:$PWD -w $PWD docker/compose -f docker-compose-metrics.yml up -d

until $(curl --output /dev/null --silent --fail localhost:5601/api/status); do
  sleep 1
done

curl -X POST "localhost:5601/api/saved_objects/_import" -H "kbn-xsrf: true" --form file=@config/kibana/filebeat.ndjson
