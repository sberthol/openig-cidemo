#!/usr/bin/env bash
# Test script for creating a secret

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=openig.master.test.com"


echo "
apiVersion: v1
kind: Secret
metadata:
  name: ssl-secret
  namespace: master
data:
  tls.crt: `base64 /tmp/tls.crt`
  tls.key: `base64 /tmp/tls.key`
" | kubectl create -f -