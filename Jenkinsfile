// Jenkinsfile

stage('checkout') {
    node {
      cleanWs()
      checkout scm
    }
  } 


// Run terraform init and plan
stage('Terraform init and plan') {
  node {
    ansiColor('xterm') {
      withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awsCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        sh'''
        terraform init
        terraform plan
        '''
      }
    }
  }
}


if (env.BRANCH_NAME == 'master') {
  // Run terraform apply
  stage('apply') {
    node {
      withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awsCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        ansiColor('xterm') {
          //sh 'terraform apply -auto-approve'
          echo 'Terraform apply'
        }
      }
    }
  }
  // Run terraform show
  stage('show') {
    node {
      withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awsCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        ansiColor('xterm') {
          //sh 'terraform show'
          echo 'terraform show'
        }
      }
    }
  }
}
  
