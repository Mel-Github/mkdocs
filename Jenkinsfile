pipeline {
  agent any
  stages {
    stage('Build Container') {
      steps {
        echo 'Docker Image Build'
        container('build')
          sh 'apk update && apk add docker'
          sh 'docker version'
      }
    }

    stage('Run Container') {
      steps {
        sh 'docker version'
      }
    }

  }
}
