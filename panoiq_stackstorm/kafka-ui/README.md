## kafka-ui deployment

Download this repository and apply the commands

```
helm repo add kafka-ui https://provectus.github.io/kafka-ui
helm install helm-release-name kafka-ui/kafka-ui
```

## cluster configuration

After the installation, Go to values.yaml file and configure kafka cluster like below

```
existingConfigMap: ""
yamlApplicationConfig:
   kafka:
     clusters:
       - name: kafka
         bootstrapServers: kafka.test:9092
```
## Service port

Modify NodePort in values.yaml like below

```
service:
  type: ClusterIP
  port: 80
  # if you want to force a specific nodePort. Must be use with service.type=NodePort
  # nodePort:

```

Now you can able to access kafka-ui by using NodePort
```
<ipaddress:port>
```




