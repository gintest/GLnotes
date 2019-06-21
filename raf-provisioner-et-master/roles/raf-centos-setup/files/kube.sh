#!/bin/bash

sleep 10s
export kubever=$(kubectl version | base64 | tr -d '\n')
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
