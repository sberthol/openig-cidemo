#!/usr/bin/env bash
# Deployment script to build a docker image and deploy to Kubernetes
# The idea here is to simplify the Jenkinsfile to just
# those things that are unique to the automated build process
# By creating a seperate deploy script you can test deployment
# without needing to commit each change to git

# source any private env vars
# Things like secrets can get set in this file. This file is not checked in to git
source env.sh


# Environment variables that are expected to get set by Jenkins - but will default if not set

BRANCH_NAME=${BRANCH_NAME:-default}
# We default build number to the timestamp in seconds
# If you use the same build number each time, k8s will think the image is the same and will not roll out a new one
# When a deployment is used.
BUILD_NUMBER=${BUILD_NUMBER:-`date +%s`}


# If command line args are supplied - they are the branch name and build number $1 $2
if [ "$#" -eq 2 ]; then
   BRANCH_NAME=$1
   BUILD_NUMBER=$2
fi

# Default k8s namespace is the git branch
NAMESPACE=${BRANCH_NAME}

# Env vars use to parameterize deployment
APP_NAME=openig
IMAGE="${APP_NAME}-custom:${BRANCH_NAME}.${BUILD_NUMBER}"

TMPDIR="/tmp/openig"

mkdir -p $TMPDIR

# If you are building on GKE and want to push to the gcr registry, use this
#GC="gcloud"
# otherwise, use this
GC=""


echo "Building Docker image $IMAGE"

$GC docker build -t $IMAGE openig

# To push to registry uncomment this
# If you are doing local development, you probably dont need to push since you
# will build direct to docker in k8s
#$GC docker push $IMAGE


kc="kubectl --namespace=${NAMESPACE}"

echo "Creating namespace ${NAMESPACE} if it does not exist"
kubectl get ns ${NAMESPACE} || kubectl create ns ${NAMESPACE}

# Generate a keystore for OpenIG
function create_keystore_secret {
 echo "creating keystore secret"
   rm -f  $TMPDIR/keystore.jks
   keytool -genkey -alias jwe-key -keyalg rsa -keystore ${TMPDIR}/keystore.jks -storepass changeit \
         -keypass changeit -dname "CN=openig.example.com,O=Example Corp"
   $kc create secret generic openig --from-file=${TMPDIR}/keystore.jks
}

# Create all the generic type secrets here...
function create_secrets {
  $kc create secret generic ig-secrets \
      --from-literal=client-id=${CLIENT_ID} \
      --from-literal=client-secret=${CLIENT_SECRET}
}

# run all the template expansions on our yaml and then deploy
function do_template {
   for file in "$@"
   do
      echo "templating $file"
      sed -e "s#IMAGE_TEMPLATE#${IMAGE}#" -e "s#NAMESPACE_TEMPLATE#${NAMESPACE}#" $file  > $TMPDIR/out.yaml
      $kc apply -f $TMPDIR/out.yaml
   done
}

# if openig keystore secret does not exist, create it
$kc get secret openig || create_keystore_secret

# if generic secrets do not exist, create it
$kc get secret  ig-secrets || create_secrets


echo "Creating/updating services"
$kc apply -f k8s/services


# todo: handle prod and canary deployments
echo "Creating/updating deployments"
do_template k8s/dev/*.yaml


# clean up
rm -fr $TMPDIR

