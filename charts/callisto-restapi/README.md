GET secrets from dev and apply to docker desktop

callisto-dev-bootstrap
callisto-dev-msk
callistodev-rds   

check current context 

```
kubectl config current-context 



kubectl get secret callisto-dev-bootstrap -o yaml --context=callisto-dev  > ./callisto-dev-bootstrap.yaml
kubectl apply -f ./callisto-dev-bootstrap.yaml

kubectl get secret callisto-dev-msk -o yaml --context=callisto-dev  > ./callisto-dev-msk.yaml
kubectl apply -f ./callisto-dev-msk.yaml

kubectl get secret callistodev-rds -o yaml --context=callisto-dev  > ./callistodev-rds.yaml
kubectl apply -f ./callistodev-rds.yaml

```


## Checking template
run in this repo

```
helm template --debug -f ./timecard-values.yaml timecard-restapi  ./charts/callisto-restapi > chart_deploy.txt
```

run in timecard repo

```
helm template --debug -f ./values/dev-values.yaml timecard  . > chart_deploy.txt     
```

compare the outputs