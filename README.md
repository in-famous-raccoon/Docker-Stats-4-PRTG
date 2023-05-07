# Configuration on Docker Host

### Install jq (example for debian/Ubuntu)
`apt install jq`

### Configure Script
#### Paste content from DockerStats4PRTG.sh to your host or clone this repo
`nano ./DockerStats4PRTG.sh`
#### Customize CONTAINERS and OUTPUT_File variable fpr example:
```
CONTAINERS="nginx-docker-prtg container1"
OUTPUT_FILE="/PATH/TO/DOCKERDATA/DockerStats4PRTG.json"
```
#### Run the script (on the first run, an error message is displayed because the file size cannot be measured)
`./DockerStats4PRTG.sh`

# Add script to crontab
`crontab -e`
### Add following line for check every 5minutes
```
*/5 * * * * $HOME/DockerStats4PRTG.sh > /dev/null
```

# Simple Nginx Server
###  Paste content from default.conf to your host or clone this repo
`nano /PATH/TO/DOCKERDATA/default.conf`

### Create and start Docker
```
docker run -d \
    --name nginx-docker-prtg \
    --restart=unless-stopped \
    -p 80:80 \
    -e USER_UID=1000 \
    -e USER_GID=1000 \
    -e TZ="Europe/Berlin" \
    -v /PATH/TO/DOCKERDATA/default.conf:/config/nginx/site-confs/default.conf:ro \
    -v /PATH/TO/DOCKERDATA/DockerStats4PRTG.json:/config/www/DockerStats4PRTG.json:ro \
    linuxserver/nginx:latest
```

# Configuration on PRTG WebUI
* Add sensor
* HTTP Data Advanced
* Name = Docker Stats
* URL = http://YOURNGINXSERVER/DockerStats4PRTG.json

##### Useful links
[PRTG custom sensors](https://www.paessler.com/manuals/prtg/custom_sensors)<br/>
[PRTG HTTP Data Advanced](https://kb.paessler.com/en/topic/66368-http-data-advanced-json-response-formatting)<br/>
[Linuxserver Docker Nginx](https://hub.docker.com/r/linuxserver/nginx)
