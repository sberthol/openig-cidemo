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

   // we hold any secrets we need in Jenkins to recreate the env.sh file
   stage('create secrets') {
      withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'oidc-secret',
            passwordVariable: 'CLIENT_SECRET', usernameVariable: 'CLIENT_ID']]) {
       writeFile file: 'env.sh', text: '''CLIENT_ID=${env.CLIENT_ID}
       CLIENT_SECRET=${env.CLIENT_SECRET}'''
      }
   }

   stage ('Run deploy') {
      sh("./deploy.sh ${env.BRANCH_NAME}")
   }

}
