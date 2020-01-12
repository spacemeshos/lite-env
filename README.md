# sm
A lite development and testing framework for Spacemesh using docker compose.

Running: `./create-all.sh`<br>
Stopping: `./delete-all.sh`<br>

Defaults are loaded from .gcp.env and defaults.env

Local sites:
- Elasticsearch: http://metrics.unruly.io:9200
- Kibana: http://metrics.unruly.io:5601
- Grafana: http://metrics.unruly.io:3000
- Prometheus: http://nodes.unruly.io:9090
