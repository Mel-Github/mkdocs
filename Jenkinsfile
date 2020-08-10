podTemplate(label: 'mypod', serviceAccount: 'jenkins', containers: [ 
    containerTemplate(
      name: 'docker', 
      image: 'docker:19.03-rc', 
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
  ]
  ) {
    node('mypod') {
        withEnv(['DOCKER_PORT=8000']){
            stage('Get latest version of code') {
              checkout scm
            } // end of stage 1
            
            stage('Performing Docker Check') {
                container('docker') {  
                    sh 'docker version'   
                }
            } // end of stage 2
            
            stage('Build container') {
                container('docker') {  
                    sh 'echo Building Container ${BUILD_ID}'   
                    sh 'docker build -t mkdocs:${BUILD_ID} .'
                    sh 'docker images'
                }
            } // end of stage 3


            stage('Run container') {
                container('docker') {  
                    // Install bash into alpine image
                    sh 'apk update'
                    sh 'apk upgrade'
                    sh 'apk add bash'

                    sh 'cat wrapper.sh'
                    // sh 'test.sh'
                    // sh './test.sh'
                    // sleep 4000
                    script {
                        sh '${WORKSPACE}/wrapper.sh -v mkdocs-${BUILD_ID} -i mkdocs:${BUILD_ID} -c build -p ${DOCKER_PORT}'
                    }
                    script {
                        sh '${WORKSPACE}/wrapper.sh -v mkdocs-${BUILD_ID} -i mkdocs:${BUILD_ID} -c serve -p ${DOCKER_PORT}'
                    }
                }
            }  // end of stage 4

           stage('Test container') {
                container('docker') {  
                    sh 'echo Testing Container ${BUILD_ID}'  
                    script {
                        env.DOCKER_PID = sh(script:'docker ps -qf "name=mkdocs-${BUILD_ID}"', returnStdout: true)                    
                    }
                    sh 'echo DOCKER_PID is ${DOCKER_PID}'
                    echo "DOCKER_PID is ${env.DOCKER_PID}"
                  
                    docker inspect --format='{{json .State.Health.Status}}' ${DOCKER_PID}
                 }
            } // end of stage 5
        } // end of withEnv
    } // end of node
}
