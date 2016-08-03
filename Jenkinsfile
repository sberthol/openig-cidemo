node {
   // If deploying images to gcr - your project name here
  def project = 'engineering-devops'
  def appName = 'openig'
  def feSvcName = "${appName}"
  // running on GKE?
  def isGKE = false

  // Generated image tag - adjust for your environment
  // example for gcr.io registry
  //def imageTag = "gcr.io/${project}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  def imageTag = "${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  // template we look for to sed replace on
  def templateImage = "forgerock/${appName}-custom:template"


  stage 'Checkout Source'
  checkout scm


  stage 'Build docker image'
  sh("docker build -t ${imageTag} ${appName}")

   if( isGKE) {
      stage 'Push image to registry'
      sh("gcloud docker push ${imageTag}")
   }
   // do a docker push here for non gcr environments..
   // sh "docker push ${imageTag}"


  stage "Deploy Application"

  // Create namespace if it doesn't exist
  sh("kubectl get ns ${env.BRANCH_NAME} || kubectl create ns ${env.BRANCH_NAME}")

   // create secret keystore. For prod you may want to have secrets created via another mechanism
   createKeystore( env.BRANCH_NAME )

   // we create the ingress even if we dont have an ingress controller. There is no harm - it is just an object
   sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/ingress/")

   // services creation is also the same across environments
   sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")


  switch (env.BRANCH_NAME) {
    // canary deployment to production
    // this doesnt do anything different right now
    //
    // todo: deploy a single canary node to a N node production cluster.
    case "canary":
        // Change deployed image to the one we just built
        sh("sed -i.bak 's#${templateImage}#${imageTag}#' ./k8s/canary/*.yaml")
        // note we deploy the canary to the *production* namespace
        sh("kubectl --namespace=production apply -f k8s/canary/")
        //sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out to production
    case "production":
        // Change deployed image to the one we just built
        sh("sed -i.bak 's#${templateImage}#${imageTag}#' ./k8s/production/*.yaml")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/production/")
        // just some
        //sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out a dev (master) or feature branch environment. Each env gets its own namespace
    default:
        // Don't use public load balancing for development branches
        // we dont currently use clusterIp - so this has no effect right now.
        sh("sed -i.bak 's#LoadBalancer#ClusterIP#' ./k8s/services/${appName}.yaml")
        // replace image template tag
        sh("sed -i.bak 's#${templateImage}#${imageTag}#' ./k8s/dev/*.yaml")

        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")

        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/${feSvcName}:80/"
        echo "or if you are using minikube:  minikube service openig -ns ${env.BRANCH_NAME}"
  }


}
// Create secret - skip this if secret exists already
def createKeystore(String branchName) {
  sh "rm -f /tmp/keystore.jks"
  sh 'keytool -genkey -alias jwe-key -keyalg rsa -keystore /tmp/keystore.jks -storepass changeit -keypass changeit -dname "CN=openig.example.com,O=Example Corp"'
  sh "kubectl --namespace=${branchName} get secret openig || kubectl --namespace=${branchName} create secret generic openig --from-file=/tmp/keystore.jks"
}