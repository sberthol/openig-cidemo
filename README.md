# Demonstrate how to deploy OpenIG to Kubernetes from a Jenkins CI pipeline 

##Warning

**This code is not supported by ForgeRock and it is your responsibility to verify that the software is suitable and safe for use.**

Largely inspired by https://github.com/GoogleCloudPlatform/continuous-deployment-on-kubernetes 

** Warning: Work in progress. Some things may be broken **

# Overview 

This project includes a Jenkins file which contains instructions on how to build an OpenIG image, push the image to 
a private repo (for example, gcr.io) and deploy it to a Kubernetes cluster. 

To use this you need:
* Jenkins CI (version 2.x - as it needs the pipeline feature and multi branch builds)
* docker and kubectl need to be available to Jenkins as it will use these commands to build and deploy images 
* Access to the OpenIG base image (openig). See https://stash.forgerock.org/projects/DOCKER/repos/docker/browse


How this works


* A branch is created to test a feature. The OpenIG configuration is held in openig/config
* When the branch is pushed, Jenkins will pick it up and start to run the pipeline defined in ./Jenkinsfile
* The pipeline creates a new child image which is configured according to openig/config
* The image is pushed to the repo or directly to docker 
* A new Kubernetes namespace is created to host the image. Each branch maps to a new namespace. This keeps different branches
isolated in the cluster. This will allow several versions to be concurrently tested.
* kubectl commands are issued to push the new image to Kubernetes. If an old image already exists, it will be replaced by
the new image (K8s deployments are used and will do a rolling update)
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
minikube service openig -ns=git-branch-name
```

This opens a browser window to the IG service. 

Note: IG does not like to be behind a proxy server where
the request context path is modified (i.e. it wants to be at the root). You
will have to adjust your IG configuration appropriately.

# Git branching model

The branching model is:
* master is the current development branch
* production represents production (treated as special by the Jenkins deployment)
* Any other branch is treated like a test branch

There is a "canary" branch concept (currently not working) but the eventual intent is to 
replace one of N instances in production with a canary container.



git branch foo
git checkout foo 
git commit -a -m foo test 
