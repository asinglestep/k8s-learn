# kube-dns
dns
version: 1.14.7

## 1. 修改kube-dns.yaml.base文件
```
将所有的 __PILLAR__DNS__DOMAIN__ 替换成 cluster.local.

将所有的 __PILLAR__DNS__SERVER__ 替换成 10.254.0.2

将 image: gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.7 改为 image: singlestep/k8s-dns-kube-dns-amd64-1.14.7:1.14.7

将 image: gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7 改为 image: singlestep/k8s-dns-dnsmasq-nanny-amd64-1.14.7:1.14.7

将 image: gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.7 改为 image: singlestep/k8s-dns-sidecar-amd64-1.14.7:1.14.7
```

## 2. 创建kube-dns
```
$ kubectl create -f kube-dns.yaml
```

## 3. 验证
```
(1). 使用nslookup测试
$ kubectl run dns-test -i -t --image=busybox --restart=Never --rm /bin/sh

$ nslookup example-service
Server:    10.254.0.2
Address 1: 10.254.0.2 kube-dns.kube-system.svc.cluster.local

Name:      example-service
Address 1: 10.254.109.88 example-service.default.svc.cluster.local
```