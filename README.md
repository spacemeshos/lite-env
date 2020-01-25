# Spacemesh Lite Environment on GCP
**A small development framework for testing spacemesh miners.**

**Run:** `./create-all.sh`<br>
*\* remember to edit config.env before running*<br>

**Stop:** `./delete-all.sh`<br>

**Metrics:**
- Kibana: http://metrics.unruly.io:5601
- Grafana: http://metrics.unruly.io:3000
- Prometheus: http://nodes.unruly.io:9090

**To add your own miner to the mesh:**
- Download the config.toml file from here: http://nodes.unruly.io
- Run: `go-spacemesh --start-mining --coinbase <account num> --tcp-port <listening port>`

