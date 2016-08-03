# Demonstrate how to deploy OpenIG to Kubernetes from a Jenkins CI pipeline 

##Warning

**This code is not supported by ForgeRock and it is your responsibility to verify that the software is suitable and safe for use.**

Inspired by https://github.com/GoogleCloudPlatform/continuous-deployment-on-kubernetes 

** Warning: Work in progress. Some things may be broken at any given time. Use at your own risk**

# Overview 

This project includes a Jenkins pipeline file  (Jenkinsfile) which contains instructions on how to build an OpenIG image, optionally push the image to 
a private repo (for example, gcr.io) and deploy it to a Kubernetes cluster. 

To use this you need:
* Jenkins CI (version 2.x - as it needs the pipeline feature and multi branch builds)
* The docker and kubectl commands need to be available to Jenkins as it will use these commands to build and deploy images 
* Access to the OpenIG base image (openig). See https://stash.forgerock.org/projects/DOCKER/repos/docker/browse

You should have a good working knowledge of Docker and Kubernetes to get this working.

# Setup 

* Fork and clone this repository 
* Create a "multi stage pipeline" job in Jenkins that uses git or github as a source 
* Start a kubernetes cluster  (minikube, gke, etc.)
* The Jenkins job runner must have access to the kubectl and docker commands to control the cluster 


# How this works


* A git branch is created to test a feature. 
* The OpenIG configuration is in openig/config and will be used to create a new Docker image
* When the branch is pushed, Jenkins will pick it up and start to run the pipeline defined in ./Jenkinsfile (note:
Jenkins currently has a bug (https://issues.jenkins-ci.org/browse/JENKINS-35310 ) where build triggers can not be saved).
* The pipeline invokes *docker build* to create a new child image which is configured according to openig/config
* The image is optionally pushed to a registry. 
* A new Kubernetes namespace is created to host the pods. Each git branch maps to a new namespace. This keeps different branches
isolated in the cluster. This will allow several versions to be concurrently tested.
* kubectl commands are issued to push the new image to Kubernetes. If an old image already exists, it will be replaced by
the new image. K8s deployments are used and will do a rolling update
* The "production" namespace is treated as special. It will cause a load balancer ingress to be created so
that the image becomes reachable from outside the cluster. 
* To reach all other namespace instances you can use kubectl port-forward to forward a local laptop port
to the cluster.  For example:

```
kubectl get pods --all-namespaces
kubectl port-forward --namespace=test openig-d86gh7 8080:8080
```


If you are using minikube, another option is to do a:

```
minikube service openig -n git-branch-name
```

This opens a browser window to the IG service. 

**Note:** IG does not like to be behind a proxy server where
the request context path is modified (i.e. it wants to be at the root). You
will have to adjust your IG configuration appropriately. You may 
wish to use an ingress even for dev branches, so you get the root context
with no url prefix.


See openig/README.md for more information on the sample IG configuration


# Git branching model

The branching model is:
* master is the current development branch
* production represents production (treated as special by the Jenkins deployment)
* Any other branch is treated like a test branch

There is a "canary" branch concept (currently not working) but the eventual intent is to 
replace one of N instances in production with a canary container.

For example, try this:
````
git branch foo
git checkout foo 
# Make changes....
git commit -a -m foo test 
# Trigger jenkins build...
```


# Fun things to try:


### Rollbacks 

Show history:

kubectl --namespace=master rollout history deployment/openig

Show a revision: 

kubectl --namespace=master rollout history deployment/openig --revision=20

Undo a rollout (optionally specify --revision=) 

kubectl --namespace=master rollout undo deployment/openig


### Autoscale your deployment:

Note: this requires heapster to be running on k8s - wont work 
out of the box on minikube

kubectl --namespace=master autoscale deployment openig --min=1 --max=4 --cpu-percent=10 

Delete autoscaling: 

kubectl --namespace=master delete hpa openig


# Useful tidbits

If you are doing development on minikube, rather than push 
to a registry, and then have k8s download the image again, it
is easier to docker build directly to the docker instance
used by k8s in minikube.  Set the imagePullPolicy appropriately in
k8s/dev/. This is the way it is currently configured. 



# Todo:

* Expand OpenIG configuration to add more examples
* Get OIDC client id / password from secrets instead of the config
files



