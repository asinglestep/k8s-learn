# 1. 为etcd创建serivce配置文件
## (1). /usr/lib/systemd/system/etcd.service
```
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/local/bin/etcd \
  --listen-client-urls ${ETCD_LISTEN_CLIENT_URLS} \
  --advertise-client-urls ${ETCD_ADVERTISE_CLIENT_URLS}
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

## (2). /etc/etcd/etcd.conf
```
# [member]
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"

#[cluster]
ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
```

# 2. 为kube-apiserver、kube-controller-manager、kube-scheduler、kubelet、kube-proxy创建serivce配置文件

## 0. /etc/kubernetes/config
```
###
# kubernetes system config
#
# The following values are used to configure various aspects of all
# kubernetes services, including
#
#   kube-apiserver.service
#   kube-controller-manager.service
#   kube-scheduler.service
#   kubelet.service
#   kube-proxy.service
# logging to stderr means we get it in the systemd journal
KUBE_LOGTOSTDERR="--logtostderr=false"

# journal message level, 0 is debug
KUBE_LOG_LEVEL="--v=0"

# 将日志文件写到/root/logs中
KUBE_LOG_DIR="--log-dir=/root/logs"

# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV="--allow-privileged=true"

# How the controller-manager, scheduler, and proxy find the apiserver
KUBE_MASTER="--master=http://127.0.0.1:8080"
```

## 1. kube-apiserver
### (1). /usr/lib/systemd/system/kube-apiserver.service
```
[Unit]
Description=Kubernetes API Service
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
After=etcd.service

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver
ExecStart=/usr/local/bin/kube-apiserver \
        $KUBE_LOGTOSTDERR \
        $KUBE_LOG_LEVEL \
        $KUBE_LOG_DIR \
        $KUBE_ETCD_SERVERS \
        $KUBE_API_ADDRESS \
        $KUBE_API_PORT \
        $KUBELET_PORT \
        $KUBE_ALLOW_PRIV \
        $KUBE_SERVICE_ADDRESSES \
        $KUBE_ADMISSION_CONTROL \
        $KUBE_API_ARGS
Restart=on-failure
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### (2). /etc/kubernetes/apiserver
```
###
## kubernetes system config
##
## The following values are used to configure the kube-apiserver
##
#
## The address on the local server to listen to.
KUBE_API_ADDRESS="--advertise-address=0.0.0.0 --bind-address=0.0.0.0 --insecure-bind-address=0.0.0.0"

## The port on the local server to listen on.
#KUBE_API_PORT="--port=8080"

## Port minions listen on
#KUBELET_PORT="--kubelet-port=10250"

## Comma separated list of nodes in the etcd cluster
KUBE_ETCD_SERVERS="--etcd-servers=http://127.0.0.1:2379"

## Address range to use for services
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"

## default admission control policies
KUBE_ADMISSION_CONTROL="--admission-control=ServiceAccount,NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota"

## Add your own!
KUBE_API_ARGS="--authorization-mode=RBAC --runtime-config=rbac.authorization.k8s.io/v1beta1 --kubelet-https=true --token-auth-file=/etc/k8s/token.csv --service-node-port-range=30000-32767 --tls-cert-file=/etc/k8s/ssl/kubernetes.pem --tls-private-key-file=/etc/k8s/ssl/kubernetes-key.pem --client-ca-file=/etc/k8s/ssl/ca.pem --service-account-key-file=/etc/k8s/ssl/ca-key.pem"
```

## 2. kube-controller-manager
### (1). /usr/lib/systemd/system/kube-controller-manager.service
```
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/controller-manager
ExecStart=/usr/local/bin/kube-controller-manager \
        $KUBE_LOGTOSTDERR \
        $KUBE_LOG_DIR \
        $KUBE_LOG_LEVEL \
        $KUBE_MASTER \
        $KUBE_CONTROLLER_MANAGER_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### (2). /etc/kubernetes/controller-manager
```
###
# The following values are used to configure the kubernetes controller-manager

# defaults from config and apiserver should be adequate

# Add your own!
KUBE_CONTROLLER_MANAGER_ARGS="--address=127.0.0.1 --service-cluster-ip-range=10.254.0.0/16 --cluster-name=kubernetes --cluster-signing-cert-file=/etc/k8s/ssl/ca.pem --cluster-signing-key-file=/etc/k8s/ssl/ca-key.pem  --service-account-private-key-file=/etc/k8s/ssl/ca-key.pem --root-ca-file=/etc/k8s/ssl/ca.pem --leader-elect=true"
```

## 3. kube-scheduler
### (1). /usr/lib/systemd/system/kube-scheduler.service 
```
[Unit]
Description=Kubernetes Scheduler Plugin
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/scheduler
ExecStart=/usr/local/bin/kube-scheduler \
            $KUBE_LOGTOSTDERR \
            $KUBE_LOG_LEVEL \
            $KUBE_LOG_DIR \
            $KUBE_MASTER \
            $KUBE_SCHEDULER_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### (2). /etc/kubernetes/scheduler
```
###
# kubernetes scheduler config

# default config should be adequate

# Add your own!
KUBE_SCHEDULER_ARGS="--leader-elect=true --address=127.0.0.1"
```

## 4. kubelet
### (1). /usr/lib/systemd/system/kubelet.service
```
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/kubelet
ExecStart=/usr/local/bin/kubelet \
            $KUBE_LOGTOSTDERR \
            $KUBE_LOG_LEVEL \
            $KUBE_LOG_DIR \
            $KUBELET_API_SERVER \
            $KUBELET_ADDRESS \
            $KUBELET_PORT \
            $KUBELET_HOSTNAME \
            $KUBE_ALLOW_PRIV \
            $KUBELET_POD_INFRA_CONTAINER \
            $KUBELET_ARGS
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### (2). /etc/kubernetes/kubelet
```
###
## kubernetes kubelet (minion) config

## The address for the info server to serve on (set to 0.0.0.0 or "" for all interfaces)
KUBELET_ADDRESS="--address=172.16.252.6"

## The port for the info server to serve on
#KUBELET_PORT="--port=10250"

## You may leave this blank to use the actual hostname
KUBELET_HOSTNAME="--hostname-override=172.16.252.6"

## pod infrastructure container
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=singlestep/pod-infrastructure"

## Add your own!
KUBELET_ARGS="--cgroup-driver=cgroupfs --cluster-dns=10.254.0.2 --experimental-bootstrap-kubeconfig=/etc/k8s/kubelet-bootstrap.kubeconfig --kubeconfig=/etc/k8s/kubelet.kubeconfig --require-kubeconfig --cert-dir=/etc/k8s/ssl --cluster-domain=cluster.local. --hairpin-mode promiscuous-bridge --serialize-image-pulls=false --fail-swap-on=false --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice"
```

## 5. kube-proxy
### (1). /usr/lib/systemd/system/kube-proxy.service
```
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/proxy
ExecStart=/usr/local/bin/kube-proxy \
        $KUBE_LOGTOSTDERR \
        $KUBE_LOG_DIR \
        $KUBE_LOG_LEVEL \
        $KUBE_MASTER \
        $KUBE_PROXY_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### (2). /etc/kubernetes/proxy
```
###
# kubernetes proxy config

# default config should be adequate

# Add your own!
KUBE_PROXY_ARGS="--bind-address=172.16.252.6 --hostname-override=172.16.252.6 --kubeconfig=/etc/k8s/kube-proxy.kubeconfig --cluster-cidr=10.254.0.0/16"
```

## 6. 启动
```
systemctl daemon-reload 
systemctl enable kube-apiserver.service kube-controller-manager.service kube-proxy.service kube-scheduler.service kubelet.service 
systemctl start kube-apiserver.service kube-controller-manager.service kube-scheduler.service kubelet.service kube-proxy.service
```