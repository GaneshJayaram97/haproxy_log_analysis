FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.6
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/