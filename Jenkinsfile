node {
   // If deploying images to gcr - your project name here
  def project = 'engineering-devops'
  def appName = 'openig'
  def feSvcName = "${appName}"
  // running on GKE?
  def isGKE = false
  // using minikube for dev?
  def isMinikube = true
  // Generated image tag - adjust for your environment
  //def imageTag = "gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  // for local minikube- we just use a branch name so we dont get image explosion
  def imageTag = "${appName}:${env.BRANCH_NAME}"
  def templateImage = "forgerock/${appName}-custom:template"

  checkout scm


  stage 'Build image'

  if( isMinikube ) {
      sh("./minidocker.sh build -t ${imageTag} ${appName}")
  }
  else
   sh("docker build -t ${imageTag} ${appName}")


   if( isGKE) {
      stage 'Push image to registry'
      sh("gcloud docker push ${imageTag}")
   }

  stage "Deploy Application"

 // Create prod namespace if it doesn't exist
 sh("kubectl get ns production || kubectl create ns production")

  switch (env.BRANCH_NAME) {
    // canary deployment to production
    // this doesnt do anything different right now - but when we
    // get multi-instance OpenAM working on Kube, it will
    // deploy a single canary node to a N node production cluster.
    case "canary":
        // Change deployed image to the one we just built
        sh("sed -i.bak 's#${templateImage}#${imageTag}#' ./k8s/canary/*.yaml")
        // note we deploy the canary to the *production* namespace
        sh("kubectl --namespace=production apply -f k8s/services/")
        sh("kubectl --namespace=production apply -f k8s/canary/")
        //sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out to production
    case "production":
        // Change deployed image in staging to the one we just built
        sh("sed -i.bak 's#${templateImage}#${imageTag}#' ./k8s/production/*.yaml")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/production/")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
        // For prod we want an ingress
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/ingress/")
        //sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out a dev (master) or feature branch environment. Each env gets its own namespace
    default:
        // Create dev branch namespace if it doesn't exist
        sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")
        // Don't use public load balancing for development branches
        sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./k8s/services/${appName}.yaml")
        sh("sed -i.bak 's#${templateImage}#${imageTag}#' ./k8s/dev/*.yaml")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")
        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/${feSvcName}:80/"
  }
}
