#!/usr/bin/env bash
# Convenice shell script that points docker to minikube's docker

eval $(minikube docker-env)

# Use docker version manager to set the right client
dvm use 1.11.2

exec docker $*
