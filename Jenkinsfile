node {
   // If deploying images to gcr - your project name here
  def project = 'engineering-devops'
  def appName = 'openig'
  def feSvcName = "${appName}"
  // running on GKE?
  def isGKE = false

  stage ('Checkout Source') {
   checkout scm
   }

   stage ('Run deploy') {
      sh("./deploy.sh ${BRANCH_NAME}")
   }

}