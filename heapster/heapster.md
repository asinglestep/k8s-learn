# heapster 
grafana     v4.4.3
heapster    v1.4.0
influxdb    v1.3.3

## 1. 获取grafana.yaml、heapster-rbac.yaml、heapster.yaml和influxdb.yaml文件
```
$ go get github.com/kubernetes/heapster
grafana.yaml、heapster.yaml和influxdb.yaml文件在$GOPATH/src/github.com/kubernetes/heapster/deploy/kube-config/influxdb/中
heapster-rbac.yaml在$GOPATH/src/github.com/kubernetes/heapster/deploy/kube-config/rbac/中
```

## 2. 启动grafana
### (1). 修改grafana.yaml
```
将 gcr.io/google_containers/heapster-grafana-amd64:v4.4.3 改为 singlestep/heapster-grafana-amd64-v4.4.3:v4.4.3
```

### (2). 创建grafana
```
$ kubectl create -f grafana.yaml
```

## 3. 启动heapster
### (1). 修改heapster.yaml文件
```
将 gcr.io/google_containers/heapster-amd64:v1.4.0 改为 singlestep/heapster-amd64-v1.4.0:v1.4.0
```

### (2). 创建heapster
```
$ kubectl create -f heapster-rbac.yaml
$ kubectl create -f heapster.yaml
```

## 4. 启动influxdb
### (1). 修改influxdb.yaml文件
```
将 gcr.io/google_containers/heapster-influxdb-amd64:v1.3.3 改为 singlestep/heapster-influxdb-amd64-v1.3.3:v1.3.3
```

### (2). 创建influxdb
```
$ kubectl create -f influxdb.yaml
```

## 5. 验证
### (1). 访问grafana
```
$ kubectl cluster-info
Kubernetes master is running at http://localhost:8080
Heapster is running at http://localhost:8080/api/v1/namespaces/kube-system/services/heapster/proxy
KubeDNS is running at http://localhost:8080/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
monitoring-grafana is running at http://localhost:8080/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy
monitoring-influxdb is running at http://localhost:8080/api/v1/namespaces/kube-system/services/monitoring-influxdb/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### (2). 访问http://172.16.221.131:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana