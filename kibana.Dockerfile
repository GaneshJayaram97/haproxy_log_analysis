FROM docker.elastic.co/kibana/kibana:7.17.6
COPY --chown=kibana:kibana kibana.yml /usr/share/kibana/config/
COPY ./haproxy_sample_dashboard.json /usr/share/kibana