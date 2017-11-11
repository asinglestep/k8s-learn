# ingress-nginx
```
提供外部可访问的URL、负载均衡、SSL、基于名称的虚拟主机等
```

## 1. 创建
```
kubectl create -f namespace.yaml
kubectl create -f default-backend.yaml
kubectl create -f configmap.yaml
kubectl create -f tcp-services-configmap.yaml
kubectl create -f udp-services-configmap.yaml
kubectl create -f rbac.yaml
kubectl create -f with-rbac.yaml
```