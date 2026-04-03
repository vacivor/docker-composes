FROM docker.elastic.co/elasticsearch/elasticsearch:8.19.12
                                                                                                                     
USER root
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch analysis-smartcn
USER elasticsearch