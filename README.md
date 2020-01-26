# Spacemesh Lite Environment on GCP
**Run:** `./create-all.sh`<br>
*\* remember to edit config.env before running*<br>

**Stop:** `./delete-all.sh`<br>

**Rerun with updated config.env:** `./update-all.sh`<br>
*\* this is much faster than stopping and running again*<br>

**Links to metrics:**
- Kibana: http://metrics.unruly.io:5601
- Grafana: http://metrics.unruly.io:3000
- Prometheus: http://nodes.unruly.io:9090

**Add your own miner:**
- Download config.toml from: http://nodes.unruly.io
- Run: `go-spacemesh --start-mining --coinbase <account num> --tcp-port <listening port>`

