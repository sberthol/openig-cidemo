node {
   // If deploying images to gcr - your project name here
  def project = 'engineering-devops'
  def appName = 'openig'
  def feSvcName = "${appName}"
  // running on GKE?
  def isGKE = false

  // Generated image tag - adjust for your environment
  //def imageTag = "gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  // for local minikube- just use a branch name if dont want to get image explosion
  // but you will have to delete the image to get k8s to redploy if the image tag does not change
  def imageTag = "${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  def templateImage = "forgerock/${appName}-custom:template"

  def createKeystore() {
     sh 'keytool -genkey -alias jwe-key -keyalg rsa -keystore /tmp/ks.jks -storepass changeit -keypass changeit -dname "CN=openig.example.com,O=Example Corp"'
     sh 'kubectl --namespace=${env.BRANCH_NAME} create secret generic ig-keystore --from-file=/tmp/ks.jks'
  }


  checkout scm


  stage 'Build image'
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
    //
    // todo: deploy a single canary node to a N node production cluster.
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
        // Change deployed image to the one we just built
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
        createKeystore()
        // Don't use public load balancing for development branches
        sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./k8s/services/${appName}.yaml")
        sh("sed -i.bak 's#${templateImage}#${imageTag}#' ./k8s/dev/*.yaml")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")
        // we create the ingress anyways - even though we might not use it in dev, there is no harm
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/ingress/")

        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/${feSvcName}:80/"
        echo "or if you are using minikube:  minikube service openig -ns ${env.BRANCH_NAME}"
  }


}
