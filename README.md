# sm
A lite development and testing framework for Spacemesh using docker compose.

Running: `./create-all.sh`<br>
Stopping: `./delete-all.sh`<br>

- Defaults are loaded from .gcp.env and defaults.env
- POET number of leaves is set inside create-poet.sh (--container-arg)
- The amount of miners is set inside create-nodes.sh (--metadata)

Local sites:
- Kibana: http://metrics.unruly.io:5601
- Prometheus: http://nodes.unruly.io:9090
- Grafana: http://metrics.unruly.io:3000
- Elasticsearch: http://metrics.unruly.io:9200
