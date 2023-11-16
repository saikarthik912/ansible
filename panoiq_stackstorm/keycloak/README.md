# keycloak
 
Installation of keycloak

```
git clone https://tempgitlab.passionbytes.io/root/tools.git
```
## Requirements
- Deployment file
- service file
- ingress file
## Deployment file
```
kubectl apply -f deployment-keycloak.yaml
```
## service file

```
kubectl apply -f service.yaml
```

## Postgresql setup
create a database in postgresql and a user with  password  and grant all privileges to the user.

```
create database key;
create user key with encrypted password 'key';
grant all privileges on database key to key;
```

Add the env variables of postgres as mentioned below in the deployment-keycloak.yaml
```

  spec:
      containers:
      - env:
        - name: BITNAMI_DEBUG
          value: "false"
        - name: KEYCLOAK_ADMIN_PASSWORD
          value: admin
        - name: KEYCLOAK_DATABASE_PASSWORD
          value: key
        - name: KEYCLOAK_HTTP_RELATIVE_PATH
          value: /

        - name: KEYCLOAK_ADMIN
          value: admin
        - name: KEYCLOAK_CACHE_TYPE
          value: local
        - name: KEYCLOAK_DATABASE_HOST
          value: postgres.development
        - name: KEYCLOAK_DATABASE_NAME
          value: key
        - name: KEYCLOAK_DATABASE_PORT
          value: "5432"
        - name: KEYCLOAK_DATABASE_USER
          value: key
        - name: KEYCLOAK_ENABLE_STATISTICS
          value: "false"
        - name: KEYCLOAK_ENABLE_TLS
          value: "false"
        - name: KEYCLOAK_HTTP_PORT
          value: "8080"
        - name: KEYCLOAK_LOG_OUTPUT
          value: default
        - name: KEYCLOAK_PROXY
          value: passthrough
```

In the KEYCLOAK_DATABASE_HOST, mention the service name and namespace of postgres

## Ingress file
```
kubectl apply -f ingress.yaml
```
As per the above configuration we can access keycloak by
```
http://IPv4address:32001
```




































