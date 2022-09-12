# HAProxy Log Analysis

This repository is created to parse/ingest/analyze the HAProxy logs using filebeats/elasticsearch/kibana services. Containerised each service to quickly start analysing the logs collected without any install dependency hassle.

## Filebeats

  Framework which is used to clean and parse the haproxy logs through the harvester. 

  Harvester is going to lookup for all the haproxy logs under the configured source directory and parse it. 
        
  The output of the parsed log is sent to Elasticsearch as batch of events

## Elasticsearch 

   Ingest the parsed the logs and used by kibana for visualising / analysing the logs and metrics


## Kibana 

   Visualisation Tool to gain better insights on the HAProxy logs

## Pre-requisites 

  ### Docker 
  Docker should be installed in the host machine
```bash
https://docs.docker.com/get-docker/
```

  ### Source Directory
   HAProxy logs should be stored under a directory in the host machine (where the docker is running) and this directory should be configured as an environment variable HAPROXY_SOURCE_DIR (set the env variable in .bashrc/.bash_profile and source it). If no directory is created, default directory service would lookup for directory under /tmp/haproxy and will fail to start if the directory is not available in the specified location

   Create a directory under $HAPROXY_SOURCE_DIR which should be same as that of system's hostname and copy and place all HAProxy logs under it and filebeat parses the logs present in this structure and ingest the hostname present in the sub-directory into elasticsearch

   Eg: 

In MAC, 
 ```
   mkdir -p /var/log/haproxy
   vi ~/.bash_profile
   export HAPROXY_SOURCE_DIR=/var/log/haproxy
   :wq (To save and quit the file)
   source ~/.bash_profile
 ```   

## Sample HAProxy Log 

```
2022-09-07 20:57:26,444129 mysystemhostname haproxy[32712]:  192.168.1.5:56134 [07/Sep/2022:20:57:26.411] frontend_service~ my_service/server_1 0/0/0/32/32 200 877 - - ---- 11/11/0/0/0 0/0 "GET https://server_1/app HTTP/2.0"
```

   Note :

   1. Log files should not be in zipped/compressed/tar format and should be raw haproxy log files



 ### Resource 
   Host machine should be good enough in terms of resources to handle the services (Filebeat, Elasticsearch, Kibana)

## Usage

Below are the steps to validate/build/create containers 
Execute the below commands from the source directory of the project 

1. Validate the docker-compose file   
```
docker-compose config
```

2. Build the container images
```
docker-compose build
```
   The above command would pick the default docker-compose.yml file and start building the images

3. Verify the built images
```
docker image ls
```

4. Run the services 
```
docker-compose up
``` 
    The above command would start all the defined services in docker-compose.yml file 

5. To run a particular service 
```
docker-compose up -d <service-name>
```
Note :

   Service Name could be found from docker-compose.yml file 

   -d option would start the container in background. Skip this option in order to start it in foreground


6. View the running containers 
```
docker container ls
```

Now the containers are up and running, copy the haproxy logs and place it in the directory defined in $HAPROXY_SOURCE_DIR in host machine and this would be picked up by filebeat's harvester. 

ES and Kibana could be accessed from host machine just like how it would be accessed when it is installed and run locally

Check ES Indices
```
curl -XGET "localhost:9200/_cat/indices?s=i&v&pretty"
```

In Browser, go to the URL for creating your own dashboards
```
http://localhost:5601
```

A Sample Dashboard has been created and can be visualised by following the below steps
1. Get the Kibana Container ID
   ```
     docker container ls
   ```

2. SSH into Kibana Container using its id which is present in the output of the above command

   ```
     docker exec -it <container-id> /bin/bash
   ```

3. Import the default dashboard present in instance 

   ```
     curl -X POST "localhost:5601/api/kibana/dashboards/import" -H "kbn-xsrf: true" -H "Content-Type: application/json" -d @haproxy_sample_dashboard.json
   ```


## Contributing
This is a bootstrap project for collecting, ingesting, visualising the HAProxy logs using the available tools in opensource and contributions are welcomed for further enhancements  

## NOTE
  1. None of the services are secured (they are run in http) as this is a bootstrap project and could be enhanced by adding them in future 
  2. Remove the files from host machine under $HAPROXY_SOURCE_DIR once ingestion is done/completed. Otherwise when the next time container starts/restarts it ingests the data and result in duplicates