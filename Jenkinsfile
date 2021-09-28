// Jenkinsfile
String credentialsId = 'JenkinsCred'

try {
  stage('checkout') {
    node {
      cleanWs()
      checkout scm
    }
  } 

  // Run terraform init
  stage('init') {
    node {
        ansiColor('xterm') {
	sh 'terraform init -backend-config="access_key=AKIA2PNUMLAC4EKECKPM" -backend-config="secret_key=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"'  
        }
    }
  }

  // Run terraform plan
  stage('plan') {
    node {
	  withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'JenkinsCred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        ansiColor('xterm') {
          sh 'terraform plan -backend-config="access_key=AKIA2PNUMLAC4EKECKPM" -backend-config="secret_key=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"' 
        }
      }
    }
  }
/*
  if (env.BRANCH_NAME == 'master') {

    // Run terraform apply
    stage('apply') {
      node {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awsCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          ansiColor('xterm') {
            sh 'terraform apply -auto-approve'
          }
        }
      }
    }

    // Run terraform show
    stage('show') {
      node {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awsCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          ansiColor('xterm') {
            sh 'terraform show'
          }
        }
      }
    }
  }
  
  currentBuild.result = 'SUCCESS'
  */
}
catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException flowError) {
  currentBuild.result = 'ABORTED'
}
catch (err) {
  currentBuild.result = 'FAILURE'
  throw err
}
finally {
  if (currentBuild.result == 'SUCCESS') {
    currentBuild.result = 'SUCCESS'
  }
}
