// Jenkinsfile that build,test,deploy artifact to S3 and update consul value


// Build and Test the app
stage('Build and Test') {
  node {
    ansiColor('xterm') {
      sh'''
      git clone https://github.com/isaacTadela/privat-unofficial-Chevrolet-
      git clone https://github.com/isaacTadela/Full-Deployment-pipeline.git
      '''
    }
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
  

// Upload artifact to S3 
stage('Upload artifact') {
  node {
    ansiColor('xterm') {
      withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awsCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        sh'''
        aws s3 ls
        '''
      }
    }
  }
}


// Update Consul KV 
stage('Update Consul') {
  node {
    ansiColor('xterm') {
      withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awsCredentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        sh'''
        aws s3 ls
        '''
      }
    }
  }
}
