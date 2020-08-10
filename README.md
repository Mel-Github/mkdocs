# mkdocs Docker Container

mkdocs is a fast, simple and downright gorgeous static site generator that's geared towards building project documentation. Details can be found in [mkdocs](https://www.mkdocs.org/)


## Pre-Requisite

The Jenkinsfile is scripted to be run on a Kubernetes running Jenkins pods. Details of Jenkins installation can be found in [Jenkins helm](https://github.com/helm/charts/tree/master/stable/jenkins)


*Note* - As the solution is built inside Kubernetes, in order to serve the application on browser, a separate pod and service k8s yaml file will need to be created.


## Instruction

There are 2 ways to run the application
- Jenkins Pipeline
- Wrapper Script



### Jenkins Pipeline

This requires Jenkins to be installed as highlighted in the [Pre-Requisite](#Pre-Requisite) section. The Jenkins Pipeline consist of the 5 stages

1. Get latest version of code
2. Performing Docker Check
3. Build container
3. Run container
4. Test container

The pipeline does not require any human intervention other than initialising the Jenkins Project with the pipeline.

The pipeline will terminate the mkdoc container if the pipeline is executed <span style="color:red">**SUCCESSFULLY**</span>


### Wrapper Script

This script allows the user to manually execute the script to perform the following operations.
- Create New Project
- Build Project
- Serve Project

The wrapper script takes 4 arguments
- -v (local directory) 
- -i (container image name) 
- -c (serve/build) 
- -p (port to map)

#### New

This step has been automated into the wrapper script. The script will read the -v argument to decide if a NEW project will be created. 


#### Build
To generate the static site assets into the site directory use. 

./wrapper.sh -v north-docs -i mkdocs -c <span style="color:red">build</span> -p 8000

#### Serve
To start a development server on http://localhost use:

 ./wrapper.sh -v north-docs -i mkdocs -c <span style="color:red">serve</span> -p 8000

