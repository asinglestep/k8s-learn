# dashboard
web-based UI

## 1. 下载kubernetes-dashboard.yaml文件
```
wget https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

## 2. 修改kubernetes-dashboard.yaml文件
```
将 gcr.io/google_containers/kubernetes-dashboard-init-amd64:v1.0.1 改为 index.tenxcloud.com/jimmy/kubernetes-dashboard-init-amd64:v1.0.1

将 gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1 改为 index.tenxcloud.com/jimmy/kubernetes-dashboard-amd64:v1.7.1
```

## 3. 创建kubernetes-dashboard
```
$ kubectl create -f kubernetes-dashboard.yaml
```

## 4. 获取dashboard的外网访问端口
```
$ kubectl -n kube-system get svc kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.254.91.174   <none>        443:31582/TCP   15m
```

## 5. 使用token访问
### (1). 创建admin用户
```
$ kubectl create -f admin-role.yaml
```

### (2). 获取secret和token的值
```
$ kubectl -n kube-system get secret | grep token
admin-token-w6vzg                  kubernetes.io/service-account-token   3         28s

$ kubectl -n kube-system describe secret admin-token-w6vzg
Name:         admin-token-w6vzg
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=admin
              kubernetes.io/service-account.uid=64fc6317-c001-11e7-a1bb-000c29468b2a

Type:  kubernetes.io/service-account-token

Data
====
namespace:  11 bytes
token:      XXXXXXXXXXXXXXXXXXXXXXX
ca.crt:     1310 bytes
```

### (3). 访问https://172.16.221.131:31582

## 6. 使用kubeconfig
### (1). 创建admin.kubeconfig
```
$ cp kubelet-bootstrap.kubeconfig admin.kubeconfig
```

### (2). 获取secret和token的值
```
$ kubectl -n kube-system get secret | grep token
admin-token-w6vzg                  kubernetes.io/service-account-token   3         28s

$ kubectl -n kube-system describe secret admin-token-w6vzg
Name:         admin-token-w6vzg
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=admin
              kubernetes.io/service-account.uid=64fc6317-c001-11e7-a1bb-000c29468b2a

Type:  kubernetes.io/service-account-token

Data
====
namespace:  11 bytes
token:      XXXXXXXXXXXXXXXXXXXXXXX
ca.crt:     1310 bytes
```

### (3). 修改admin.kubeconfig
```
将admin.kubeconfig的token替换成获取到的token
```

### (4). 访问https://172.16.221.131:31582