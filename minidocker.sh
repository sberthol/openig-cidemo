#!/usr/bin/env bash
# Convenience shell script that points docker to minikube's docker
# Source this

eval $(minikube docker-env)

# Use docker version manager to set the right client
dvm use 1.11.2

echo `which docker`

source "$(brew --prefix dvm)/dvm.sh"

