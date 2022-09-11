FROM docker.elastic.co/beats/filebeat:7.17.6
COPY --chown=root:filebeat filebeat.docker.yml /usr/share/filebeat/filebeat.yml
COPY ./modules.d/* /usr/share/filebeat/modules.d/