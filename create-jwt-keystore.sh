#!/usr/bin/env bash
keytool \
 -genkey \
 -alias jwe-key \
 -keyalg rsa \
 -keystore /tmp/keystore.jks \
 -storepass changeit \
 -keypass changeit \
 -dname "CN=openig.example.com,O=Example Corp"


kubectl create secret generic ig-keystore --from-file=/tmp/keystore.jks

