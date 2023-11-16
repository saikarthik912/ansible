#!/bin/sh


kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "CREATE DATABASE air;"

kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "CREATE USER air WITH ENCRYPTED PASSWORD 'air';"

kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE air TO air;"




kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "CREATE DATABASE key;"

kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "CREATE USER key WITH ENCRYPTED PASSWORD 'key';"

kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE key TO key;"




kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "CREATE DATABASE hive;"

kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "CREATE USER hive WITH ENCRYPTED PASSWORD 'hive';"

kubectl exec -n tools -it $(kubectl get pods -n tools -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE hive TO hive;"
