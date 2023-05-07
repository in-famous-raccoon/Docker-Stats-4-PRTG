#!/bin/bash
CONTAINERS="Container1 Container2 nginx"
OUTPUT_FILE="/PATH/TO/DOCKERDATA/DockerStats4PRTG.json"

fileage=$(($(date +%s) - $(date -r "$OUTPUT_FILE" +%s)))
count_containers=$(/usr/bin/docker ps -q | wc -l)

output="{ \"prtg\": { \"result\": [ { \"channel\": \"RunningContainers\", \"value\": \"$count_containers\", \"limitmode\": 1, \"limitmaxwarning\": \"25\", \"limitmaxerror\": \"30\" },"
for container in $CONTAINERS
  do
  checkstate=$(/usr/bin/docker inspect --format='{{.State.Status}}' $container)
  if [[ "$checkstate" == *"created" ]];then state="0"
    elif [[ "$checkstate" == *"running" ]];then state="1"
    elif [[ "$checkstate" == *"paused" ]];then state="100"
    elif [[ "$checkstate" == *"restarting" ]];then state="101"
    elif [[ "$checkstate" == *"exited" ]];then state="200"
    elif [[ "$checkstate" == *"dead" ]];then state="200"
    else state="300"
  fi
  output="$output { \"channel\": \"$container State\", \"value\": \"$state\", \"valuelookup\": \"prtg.standardlookups.docker.containerstatus\" },"
  cpu=$(/usr/bin/docker stats --no-stream --format "{{ .CPUPerc }}" $container | tr -d '%')
  output="$output { \"channel\": \"$container CPU Usage\", \"value\": \"$cpu\", \"float\": 1, \"unit\": \"cpu\", \"limitmode\": 1, \"limitmaxwarning\": \"70\", \"limitmaxerror\": \"90\" },"
  mem=$(/usr/bin/docker stats --no-stream --format "{{ .MemPerc }}" $container | tr -d '%')
  output="$output { \"channel\": \"$container Memory Usage\", \"value\": \"$mem\", \"float\": 1, \"unit\": \"percent\", \"limitmode\": 1, \"limitmaxwarning\": \"70\", \"limitmaxerror\": \"90\" },"
  done
  output="$output { \"channel\": \"FileAge\", \"value\": \"$fileage\", \"unit\": \"timeseconds\" } ], \"text\": \"LastRun $(date '+%d.%m.%Y %T')\" } }"

echo $output | jq '.' > $OUTPUT_FILE
