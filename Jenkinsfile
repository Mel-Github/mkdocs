pipeline {
  agent {
    docker {
      image 'node:14-alpine'
    }

  }
  stages {
    stage('Build Container') {
      steps {
        echo 'Docker Image Build'
        sh 'docker version'
      }
    }

  }
}