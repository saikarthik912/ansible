FROM apache/airflow:2.3.0

##SSO config
RUN  rm -rf /opt/airflow/webserver_config.py
COPY webserver_config.py /opt/airflow/webserver_config.py



RUN pip3 install apache-airflow-providers-apache-spark
RUN pip3 install apache-airflow-providers-cncf-kubernetes
RUN pip3 install minio

USER root
RUN mkdir /opt/airflow/executables/ -p
RUN apt-get update -y
RUN apt-get install openjdk-11-jdk -y
RUN export JAVA_HOME=/usr/bin/java

COPY spark-3.2.3-bin-hadoop3.2/ /opt/spark/
ENV  SPARK_HOME=/opt/spark
ENV  PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin


RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

RUN chmod +x $HOME/minio-binaries/mc

ENV PATH = $PATH:$HOME/minio-binaries/

RUN $HOME/minio-binaries/mc --help

#RUN apt-get install python3 -y

#CMD ["apt-get purge python python3 python3.7 python3.9 -y"]
#CMD ["apt-get autoremove python python3 python3.7 python3.9 -y"]
#CMD ["apt-get install python3.9 -y"]
#CMD ["rm /usr/local/bin/python3"]
#CMD ["ln -s /usr/bin/python3.9 /usr/local/bin/python3"]

#RUN apt-get purge python python3 python3.7 python3.9 -y
#RUN apt-get autoremove python python3 python3.7 python3.9 -y
#RUN apt-get install python3.9 -y
#RUN rm /usr/local/bin/python3
#RUN ln -s /usr/bin/python3.9 /usr/local/bin/python3


#ENTRYPOINT ["python3"]

#RUN alias python=python3



