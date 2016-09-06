# Gatling example

This is an example of running a gatling test inside of Kubernetes.



For this example, we assume OpenIG is running in the default namespace

Steps to run:
* Create your gatling test in perftest/IGPerftest.scala. 
* Build the docker image for gating using ./build.sh. 
* Optionally push that image to a registry that your k8s cluster can access. 
For minikube, we just docker build direct to the cluster
* Run the gatling job:  ```kubectl create -f gatling-job.yaml```

For this exmaple, we use a hostPath volume to output the results. 

You can serve up the results files using:

```kubectl create -f web.yaml```

If you are using minikube, you can view the results with:

```minikube service web-results```

You may need to modify this example for your specific use case.



