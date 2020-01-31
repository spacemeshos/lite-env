# Spacemesh Lite Environment on GCP

### Start: `./create-all.sh`  
Deletes the old VM's, creates new ones (poet, metrics, nodes) and starts a network using `./config.env`.

### Stop: `./delete-all.sh`  
Deletes the old VM's. Don't forget to run this when done.

### Update: `./update-all.sh`  
Starts a new network on existing VM's (without recreating them) using a fresh `./config.env`. It's like `./create-all.sh` on steroids.

### Connect your own miner:
* Download `config.toml` from: http://nodes.unruly.io  
* Run: `go-spacemesh --start-mining --coinbase <account num> --tcp-port <listening port>`

**Metrics and logs:**  

| Website | Link |
| --- | --- |
| Kibana | http://metrics.unruly.io:5601 |
| Grafana | http://metrics.unruly.io:3000 |
| Prometheus | http://nodes.unruly.io:9090 |


**To SSH into a VM:** `gcloud compute ssh <poet|metrics|nodes>`  

| Want to: | Add: |
| --- | --- |
|SSH into a container | `--container <container name>`|
|Tail a container's log | `--command "docker logs <container name> -f"`|
|Follow VM's process | `--command "sudo toolbox bash -c 'htop'" -- -t`|
|Get VM's disk usage | `--command "df -h /dev/sda1"`|
