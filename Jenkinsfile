podTemplate(label: 'mypod', serviceAccount: 'jenkins', containers: [ 
    containerTemplate(
      name: 'docker', 
      image: 'docker', 
      command: 'cat', 
      resourceRequestCpu: '100m',
      resourceLimitCpu: '300m',
      resourceRequestMemory: '300Mi',
      resourceLimitMemory: '500Mi',
      ttyEnabled: true,
    )
  ],
            
  volumes: [
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
    hostPathVolume(mountPath: '/usr/local/bin/helm', hostPath: '/usr/local/bin/helm')
  ]
  ) {
    node('mypod') {
        stage('Get latest version of code') {
          checkout scm
        }
        stage('Performing Docker Check') {
            container('docker') {  
                sh 'docker version'    
            }
        }
        stage('Build container') {
            container('docker') {  
                sh 'echo Building Container ${BUILD_ID}'   
                sh 'docker build -t mkdocs:${BUILD_ID} .'
                sh 'docker images'
            }
        }    
        stage('Test container') {
             environment {
                DOCKER_PORT = '80'
            }
            container('docker') {  
                sh """
                ./wrapper.sh -v mkdocs-${BUILD_ID} -i mkdocs:${BUILD_ID} -c build -p ${DOCKER_PORT}
                """
            }
        }  
    }
}
