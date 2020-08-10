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
                    
                    // Build the MkDocs projects followed by Serve
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
                    // Extract the docker id of the MkDoc container. This value will be used for terminating the container later.
                    script {
                        env.DOCKER_PID = sh(script:'docker ps -qf "name=mkdocs-${BUILD_ID}"', returnStdout: true)                    
                    }
                    sh 'echo DOCKER_PID is ${DOCKER_PID}'
                    echo "DOCKER_PID is ${env.DOCKER_PID}"
                    
                    // Adding 30 secs delay for application to launch
                    sleep 30
                    
                    // Using the HEALTHCHECK implemented in the docker container to determine the container Health status.
                    script {
                        env.HEALTHSTATUS = sh(script:'docker inspect --format="{{json .State.Health.Status}}" ${DOCKER_PID}', returnStdout: true).trim()
                    }
                    
                    echo "Container Health status is ${HEALTHSTATUS}"
 
                    if (env.HEALTHSTATUS == "\"healthy\"") {
                        echo "[ INFO ]: Container health status ${HEALTHSTATUS}"
                        echo "[ INFO ]: Terminating Build ${BUILD_ID}"
                        sh 'docker kill ${DOCKER_PID} '
                        
                    } else {
                        echo "[ ERROR ]: Container health status ${HEALTHSTATUS}" 
                        currentBuild.rawBuild.result = Result.ABORTED
                        throw new hudson.AbortException('Container Testing Failed!')
                    }
                 }
            } // end of stage 5
        } // end of withEnv
    } // end of node
}
