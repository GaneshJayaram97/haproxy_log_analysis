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

A Sample Dashboard has been created and can be visualised by clicking the following link 
```
http://localhost:5601/app/dashboards#/view/ca7db070-3121-11ed-9962-4beef156be9f?embed=true&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2022-09-07T12:45:00.000Z',to:'2022-09-07T13:15:00.000Z'))&_a=(description:'',filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:b950f7d0-311c-11ed-9962-4beef156be9f,key:haproxy.backend_name,negate:!f,params:!(active_service,be_ppolltrfm00012.unix.gsm1900.org,localfm,member_service),type:phrases),query:(bool:(minimum_should_match:1,should:!((match_phrase:(haproxy.backend_name:active_service)),(match_phrase:(haproxy.backend_name:be_ppolltrfm00012.unix.gsm1900.org)),(match_phrase:(haproxy.backend_name:localfm)),(match_phrase:(haproxy.backend_name:member_service)))))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:b950f7d0-311c-11ed-9962-4beef156be9f,key:haproxy.server_name,negate:!t,params:!(server_ppolltrfm00011.unix.gsm1900.org,server_ppolltrfm00012.unix.gsm1900.org),type:phrases),query:(bool:(minimum_should_match:1,should:!((match_phrase:(haproxy.server_name:server_ppolltrfm00011.unix.gsm1900.org)),(match_phrase:(haproxy.server_name:server_ppolltrfm00012.unix.gsm1900.org))))))),fullScreenMode:!f,options:(hidePanelTitles:!f,syncColors:!f,useMargins:!t),panels:!((embeddableConfig:(enhancements:(),hidePanelTitles:!f,savedVis:(data:(aggs:!(),searchSource:(filter:!(),query:(language:kuery,query:''))),description:'',id:'',params:(axis_formatter:number,axis_position:left,axis_scale:normal,bar_color_rules:!((id:'4a237ba0-311f-11ed-8277-c593f951c3fe')),drop_last_bucket:0,id:'75289bb6-b78a-46f1-ab30-44656b53037f',index_pattern:(id:b950f7d0-311c-11ed-9962-4beef156be9f),interval:'30m',isModelInvalid:!f,max_lines_legend:1,series:!((axis_position:right,chart_type:line,color:%2368BC00,fill:0.5,formatter:default,id:'58548771-796c-42fe-bf58-65035ecd26fd',label:'Top%20API%20Requests',line_width:1,metrics:!((agg_with:max,field:haproxy.http.request.time_wait_without_data_ms,id:b38cb071-a3d6-45f5-8d3e-2e27652387c2,order:desc,order_by:'@timestamp',size:'1',type:max)),override_index_pattern:0,palette:(name:default,type:palette),point_size:1,separate_axis:0,series_drop_last_bucket:0,split_mode:terms,stacked:none,terms_direction:desc,terms_field:haproxy.http.request.raw_request_line.keyword,terms_order_by:b38cb071-a3d6-45f5-8d3e-2e27652387c2,terms_size:'1000',time_range_mode:entire_time_range)),show_grid:1,show_legend:1,time_field:'@timestamp',time_range_mode:entire_time_range,tooltip_mode:show_all,truncate_legend:1,type:top_n,use_kibana_indexes:!t),title:'',type:metrics,uiState:())),gridData:(h:8,i:a8c31c6a-a7f8-414d-b81e-6114aad963e4,w:48,x:0,y:0),panelIndex:a8c31c6a-a7f8-414d-b81e-6114aad963e4,title:'Top%20100%20Time%20Consuming%20API(s)',type:visualization,version:'7.17.6'),(embeddableConfig:(enhancements:(),hidePanelTitles:!f,savedVis:(data:(aggs:!(),searchSource:(filter:!(),query:(language:kuery,query:''))),description:'',id:'',params:(axis_formatter:number,axis_position:left,axis_scale:normal,bar_color_rules:!((id:'1c22fe40-3130-11ed-9338-f7d8a16d1533')),drop_last_bucket:0,id:f73ea18e-0cef-424a-8bb3-0bf42778caf3,index_pattern:'',interval:'',isModelInvalid:!f,max_lines_legend:1,pivot_id:haproxy.http.request.raw_request_line.keyword,pivot_label:'HTTP%20Request',pivot_rows:'200',pivot_type:string,series:!((axis_position:right,chart_type:line,color:%2368BC00,fill:0.5,formatter:default,id:'2b62606c-411f-45b2-8414-43a5b10e599c',label:'Requests%20by%20Count',line_width:1,metrics:!((id:cb2d0a74-7ba1-4bd2-920d-88739fba0b91,type:count)),override_index_pattern:0,palette:(name:default,type:palette),point_size:1,separate_axis:0,series_drop_last_bucket:0,split_mode:everything,stacked:none,time_range_mode:entire_time_range)),show_grid:1,show_legend:1,time_field:'',time_range_mode:entire_time_range,tooltip_mode:show_all,truncate_legend:1,type:table,use_kibana_indexes:!t),title:'',type:metrics,uiState:()),table:(sort:(column:'2b62606c-411f-45b2-8414-43a5b10e599c',order:desc))),gridData:(h:8,i:'98eecbc5-9fd6-4055-9677-629f387fb67a',w:48,x:0,y:8),panelIndex:'98eecbc5-9fd6-4055-9677-629f387fb67a',title:'Requests%20By%20Count',type:visualization,version:'7.17.6'),(embeddableConfig:(enhancements:(),hidePanelTitles:!f,savedVis:(data:(aggs:!(),searchSource:(filter:!(),query:(language:kuery,query:''))),description:'',id:'',params:(axis_formatter:number,axis_position:left,axis_scale:normal,bar_color_rules:!((id:'96b27400-3122-11ed-8277-c593f951c3fe')),drop_last_bucket:0,id:'3c41c2e3-a419-47ab-9fc9-5d2b2b9f0239',index_pattern:(id:b950f7d0-311c-11ed-9962-4beef156be9f),interval:'10m',isModelInvalid:!f,max_lines_legend:1,pivot_id:'@timestamp',pivot_type:date,series:!((axis_position:right,chart_type:line,color:%2368BC00,fill:0.5,filter:(language:kuery,query:'haproxy.frontend_name%20:%20%22fmha~%22%20%20'),formatter:default,id:'499e13db-5992-4b6b-909a-74b7f2366fc7',label:'Requests%20Rate',line_width:1,metrics:!((id:'8027dc7d-f14f-4d7b-9fc3-ce0c5c6f8280',type:count)),override_index_pattern:0,palette:(name:default,type:palette),point_size:1,separate_axis:0,series_drop_last_bucket:0,split_mode:filter,stacked:none,time_range_mode:entire_time_range)),show_grid:1,show_legend:1,time_field:'@timestamp',time_range_mode:entire_time_range,tooltip_mode:show_all,truncate_legend:1,type:timeseries,use_kibana_indexes:!t),title:'',type:metrics,uiState:())),gridData:(h:11,i:'2e60b4e2-cb80-4d75-9ec8-c065ad48b3fd',w:48,x:0,y:26),panelIndex:'2e60b4e2-cb80-4d75-9ec8-c065ad48b3fd',title:'HTTP%20Requests%20Trend',type:visualization,version:'7.17.6'),(embeddableConfig:(enhancements:(),hidePanelTitles:!f,savedVis:(data:(aggs:!(),searchSource:(filter:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:b950f7d0-311c-11ed-9962-4beef156be9f,key:source.address,negate:!t,params:!('10.135.50.88','10.135.49.186','10.135.49.187'),type:phrases),query:(bool:(minimum_should_match:1,should:!((match_phrase:(source.address:'10.135.50.88')),(match_phrase:(source.address:'10.135.49.186')),(match_phrase:(source.address:'10.135.49.187'))))))),query:(language:kuery,query:''))),description:'',id:'',params:(axis_formatter:number,axis_position:left,axis_scale:normal,bar_color_rules:!((id:de700e30-3125-11ed-8277-c593f951c3fe)),drop_last_bucket:0,id:b4a128aa-50bc-4c43-a2a0-841861ecff0a,index_pattern:'',interval:'',max_lines_legend:1,pivot_id:source.address.keyword,pivot_label:'Source%20Address',pivot_rows:'250',pivot_type:string,series:!((axis_position:right,chart_type:line,color:%2368BC00,fill:0.5,formatter:default,id:'4da807c4-ecc5-4cdb-bba1-0c96511efdb1',line_width:1,metrics:!((id:'2f55b806-b157-4744-a003-a8f15fad4c05',type:count)),override_index_pattern:0,palette:(name:default,type:palette),point_size:1,separate_axis:0,series_drop_last_bucket:0,split_mode:everything,stacked:none,time_range_mode:entire_time_range)),show_grid:1,show_legend:1,time_field:'',time_range_mode:entire_time_range,tooltip_mode:show_all,truncate_legend:1,type:table,use_kibana_indexes:!t),title:'',type:metrics,uiState:())),gridData:(h:13,i:dc1afd20-b368-455c-b5ac-960f327cfcf5,w:48,x:0,y:37),panelIndex:dc1afd20-b368-455c-b5ac-960f327cfcf5,title:'Top%20Requests%20by%20Servers',type:visualization,version:'7.17.6'),(embeddableConfig:(enhancements:(),hidePanelTitles:!f,savedVis:(data:(aggs:!(),searchSource:(filter:!(),query:(language:kuery,query:''))),description:'',id:'',params:(axis_formatter:number,axis_position:left,axis_scale:normal,bar_color_rules:!((id:da818d90-3133-11ed-bce3-f7acf90f4073)),drop_last_bucket:0,id:'96a0bc08-8364-4150-a8ce-a2651bc3512e',index_pattern:'',interval:'',max_lines_legend:1,pivot_id:url.path.keyword,pivot_label:'URL%20Path',pivot_rows:'200',pivot_type:string,series:!((axis_position:right,chart_type:line,color:%2368BC00,fill:0.5,formatter:default,id:'9f0f74a8-2370-4c64-889c-45c2b83e1c7e',label:'URL%20Requests%20By%20Count',line_width:1,metrics:!((id:'9ba3f7bc-6909-42bb-9a9b-863671fbbace',type:count)),override_index_pattern:0,palette:(name:default,type:palette),point_size:1,separate_axis:0,series_drop_last_bucket:0,split_mode:everything,stacked:none,time_range_mode:entire_time_range)),show_grid:1,show_legend:1,time_field:'',time_range_mode:entire_time_range,tooltip_mode:show_all,truncate_legend:1,type:table,use_kibana_indexes:!t),title:'',type:metrics,uiState:()),table:(sort:(column:'9f0f74a8-2370-4c64-889c-45c2b83e1c7e',order:desc))),gridData:(h:10,i:badac1a1-7eae-4de2-9a81-739ee2a1082b,w:48,x:0,y:16),panelIndex:badac1a1-7eae-4de2-9a81-739ee2a1082b,title:'URL%20Requests%20By%20Count',type:visualization,version:'7.17.6')),query:(language:kuery,query:''),tags:!(bcf15dd0-3121-11ed-9962-4beef156be9f,c0a36950-3121-11ed-9962-4beef156be9f,c8729e30-3121-11ed-9962-4beef156be9f),timeRestore:!t,title:'HAProxy%20API%20Analysis',viewMode:view)&show-top-menu=true&show-query-input=true&show-time-filter=true" height="600" width="800"
```


## Contributing
This is a bootstrap project for collecting, ingesting, visualising the HAProxy logs using the available tools in opensource and contributions are welcomed for further enhancements  

## NOTE
  1. None of the services are secured (they are run in http) as this is a bootstrap project and could be enhanced by adding them in future 
