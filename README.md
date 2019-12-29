# sm
A lite development and testing framework for Spacemesh using docker compose.

Running: `docker-compose up --scale node=<number of nodes>`
<br>
Stopping: `docker-compose down -v`

Good to know:
- To force image build add: `--build`
- List services: `docker-compose ps`
- To open shell inside a running container: `docker exec -it <name> sh`
- Defaults are loaded from defaults.env and overridden inside docker.compose.yml with "environment:"
- Fluentbit logs are saved under ./logs

Local websites:
- Kibana: http://localhost:5601
- Prometheus: http://localhost:9999
- Grafana: http://localhost:3000
- Elasticsearch: http://localhost:9200
- Cerebro: http://localhost:9000
