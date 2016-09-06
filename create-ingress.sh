#!/usr/bin/env bash
# Creates an optional ingress controller to load balance your services
# If you are running on  a turnkey cloud (AWS, GCE) you don't need this as an ingress controller is provided for you
# Use this for minikube, or other environments
# See https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx

P="https://raw.githubusercontent.com/kubernetes/contrib/master/ingress/controllers/nginx"

curl -s "$P/examples/default-backend.yaml" | kubectl create -f -

kubectl expose rc default-http-backend --port=80 --target-port=8080 --name=default-http-backend

curl -s "$P/examples/default/rc-default.yaml" | kubectl create  -f -
