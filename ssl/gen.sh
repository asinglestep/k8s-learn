#!/bin/zsh
# 创建证书、token和kubeconfig文件
# 将文件拷贝到服务器上

# 生成证书
genCert() {
    cfssl gencert -initca ca-csr.json | cfssljson -bare ca
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy
}

# 生成token
genToken() {
    export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
    echo ${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap" > token.csv
}

# 生成kubeconfig
genConfig() {
    kubectl config set-cluster kubernetes --certificate-authority=ca.pem  --embed-certs=true --server=https://172.16.221.131:6443 --kubeconfig=kubelet-bootstrap.kubeconfig

    kubectl config set-credentials kubelet-bootstrap --token=${BOOTSTRAP_TOKEN} --kubeconfig=kubelet-bootstrap.kubeconfig

    kubectl config set-context default  --cluster=kubernetes --user=kubelet-bootstrap  --kubeconfig=kubelet-bootstrap.kubeconfig

    kubectl config use-context default --kubeconfig=kubelet-bootstrap.kubeconfig

    kubectl config set-cluster kubernetes --certificate-authority=ca.pem --embed-certs=true --server=https://172.16.221.131:6443 --kubeconfig=kube-proxy.kubeconfig

    kubectl config set-credentials kube-proxy --client-certificate=kube-proxy.pem  --client-key=kube-proxy-key.pem --embed-certs=true --kubeconfig=kube-proxy.kubeconfig

    kubectl config set-context default --cluster=kubernetes  --user=kube-proxy --kubeconfig=kube-proxy.kubeconfig

    kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

main() {
    if [[ ! -n $@ ]];then 
        echo "Usage: main [ip]"
        exit
    fi

    genCert

    genToken

    genConfig

    tar cf k8s.tar *.pem *.kubeconfig token.csv

    for ip in $@
    do
        ssh root@$ip 'mkdir -p /etc/k8s/ssl'
        scp k8s.tar root@$ip:/etc/k8s/ssl
        ssh root@$ip 'cd /etc/k8s/ssl && tar xf k8s.tar && mv *.kubeconfig token.csv ../ && rm k8s.tar'
    done
    
    ls | grep -v json | grep -v gen.sh | xargs rm 
}

main 172.16.221.131 172.16.221.130 172.16.221.129