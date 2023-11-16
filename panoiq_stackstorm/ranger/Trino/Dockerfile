#!/bin/bash
FROM trinodb/trino

# USER root
# WORKDIR /opt

# ADD ranger-3.0.0-SNAPSHOT-trino-plugin /opt






COPY install.properties /root
COPY docker-entrypoint.sh /root/

# COPY install.properties /root/ranger-3.0.0-SNAPSHOT-trino-plugin-405-406/
# RUN /opt/ranger-3.0.0-SNAPSHOT-trino-plugin/enable-trino-plugin.sh

USER root

# RUN sh /root/docker-entrypoint.sh





# RUN  chown root:root -R  /etc/trino/*

ENTRYPOINT ["sh", "/root/docker-entrypoint.sh"]
 
