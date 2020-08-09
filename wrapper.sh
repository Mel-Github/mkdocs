#!/bin/bash
set -e

readonly MKDOCS_CONFIG=mkdocs.yml
readonly DOCKERFILE=dockerfile
MKDOCS_DOCKER_WORKDIR="" #This value is mapped back with the Dockerfile WORKDIR
MKDOCS_DEFAULT_PROJECT=default-project

helpFunction()
{
   echo ""
   echo "Usage: $0 -p <DOCKER PORT> -i <DOCKE R IMAGE> -v <LOCAL DIRECTORY> -c <MKDOCS COMMAND [build / serve]"
   echo -e "\t[COMMANDS]"
   echo -e "\t-v Local MkDocs Project Directory"
   echo -e "\t-i Docker Container Image Name"
   echo -e "\t-c MkDocs BUILD or SERVER Command"
   echo -e "\t-p Docker Port"
   exit 1 # Exit script after printing help
}

while getopts "p:i:c:v:n:" opt
do
   case "$opt" in
      p ) DOCKER_PORT="$OPTARG" ;;
      i ) DOCKER_IMAGE="$OPTARG" ;;
      c ) COMMAND="$OPTARG" ;;
      v ) WORKSPACE="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done


echo "MKDOCS_DEFAULT_PROJECT is $MKDOCS_DEFAULT_PROJECT"

# Read from Dockerfile the WORKDIR value which we will need to map to docker volume later.
if ! [[ -f $DOCKERFILE ]]; then
  echo "[ ERROR ]: Unable to locate dockerfile."
  exit 1
fi

while read line; do
# reading each line
if [[ $line == "WORKDIR"* ]]; then 
  # echo $line
  workdir=( $line )
  MKDOCS_DOCKER_WORKDIR=${workdir[1]}
  echo "[ INFO ]: The WORKDIR is $MKDOCS_DOCKER_WORKDIR"
fi
done < $DOCKERFILE

# Check docker command is installed
echo "[ INFO ]: Checking docker is available"
docker --version >> /dev/null

if [ $? -ne 0 ]; then
  echo "[ ERROR ]: Unable to detect docker is installed."
  exit 1
else
  echo "[ INFO ]: docker check passed."
fi

# Print helpFunction in case parameters are empty
if [ -z "$DOCKER_PORT" ] || [ -z "$DOCKER_IMAGE" ] || [ -z "$COMMAND" ] || [ -z "$WORKSPACE" ]
then
   echo "[ ERROR ]: Some or all of the parameters are empty";
   helpFunction
fi


# Check that the DOCKER PORT is valid integer
if ! [[ $DOCKER_PORT =~ ^-?[0-9]+$ ]]
then
  echo "[ ERROR ]: DOCKER_PORT is not a valid integer."
  exit 1
fi


# Check that the DOCKER IMAGE exist
CONTAINER_NAME=$DOCKER_IMAGE
if [[ "$(docker images -q "$CONTAINER_NAME" 2> /dev/null)" == "" ]]; then
  echo "[ ERROR ]: Docker Image $CONTAINER_NAME not found."
  echo "*Hint*: Have Docker build tag \"$CONTAINER_NAME\" has been executed"
  exit 1
fi


# Check that COMMAND is valid
LC_COMMAND=$(echo $COMMAND | tr '[:upper:]' '[:lower:]')


if ! [[ "$LC_COMMAND" =~ ^(build|serve)$ ]]; then
  echo "[ ERROR ]: COMMAND -c parameter : build / serve"
  helpFunction
  exit 1
fi


# Check that local WORKSPACE is valid
if [[ ! -d "$WORKSPACE" ]]; then
  echo "[ ERROR ]: $WORKSPACE does not exist locally"
  #  echo "Workspace is $WORKSPACE & mkdocs_config $MKDOCS_CONFIG and path is ${PWD}/$WORKSPACE/$MKDOCS_CONFIG "
  docker run -v ${PWD}:/$MKDOCS_DOCKER_WORKDIR $DOCKER_IMAGE new $WORKSPACE
  MKDOC_PROJECT=$WORKSPACE
  ## helpFunction
  ## exit 1
else 
  # Check that the WORKSPACE contains the mkdocs.yml file. If not we need to generate a NEW MKDOCS project.
  # Assumption we will auto generate a NEW MKDOCS project.

  echo "[ INFO ]: Checking if $WORKSPACE is valid Mkdocs project"
  if [ -f "$WORKSPACE/$MKDOCS_CONFIG" ]; then
    echo "[ INFO ]: $MKDOCS_CONFIG found."
    MKDOC_PROJECT=$WORKSPACE
  else 
    echo "[ INFO ]: $MKDOCS_CONFIG missing. Generating new Mkdocs project"
    # MKDOC_PROJECT=$WORKSPACE/$MKDOCS_DEFAULT_PROJECT
    MKDOC_PROJECT=$WORKSPACE
    if ! [ -f "$WORKSPACE/$MKDOCS_CONFIG" ]; then
      # docker run -v ${PWD}/$WORKSPACE:/$MKDOCS_DOCKER_WORKDIR $DOCKER_IMAGE new $MKDOCS_DEFAULT_PROJECT 
      docker run -v ${PWD}:/$MKDOCS_DOCKER_WORKDIR $DOCKER_IMAGE new $WORKSPACE
    else
       echo "[ INFO ]: $MKDOCS_CONFIG found inside $WORKSPACE/$MKDOCS_DEFAULT_PROJECT. Skipping project creation."
    fi
    echo "[ INFO ]: Successfully created $MKDOCS_DEFAULT_PROJECT"
  fi
fi

# Begin script in case all parameters are correct
echo 
echo "*********************************************"
echo "            [OPTIONS] SUMMARY                "
echo "*********************************************"
echo "[ INFO ]: Docker Port      -  $DOCKER_PORT"
echo "[ INFO ]: Docker Iamge     -  $DOCKER_IMAGE"
echo "[ INFO ]: MkDocs Command   -  $COMMAND"
echo "[ INFO ]: Local Directory  -  $WORKSPACE"
echo "[ INFO ]: MkDocs Project   -  $MKDOC_PROJECT"


case "$LC_COMMAND" in
        build)
            echo ""
            echo "*********************************************"
            echo "            [$LC_COMMAND] COMMAND            "
            echo "*********************************************"
            echo "[ INFO ]: $LC_COMMAND"
            docker run -v ${PWD}/$MKDOC_PROJECT:$MKDOCS_DOCKER_WORKDIR $DOCKER_IMAGE build
            echo "[ INFO ]: Project Successfully $LC_COMMAND."
            ;;
         
        serve)
            echo ""
            echo "*********************************************"
            echo "            [$LC_COMMAND] COMMAND            "
            echo "*********************************************"
            echo "[ INFO ]: $LC_COMMAND"
            # echo "docker run -v ${PWD}/$MKDOC_PROJECT:$MKDOCS_DOCKER_WORKDIR -it -d --rm  -p $DOCKER_PORT:8000  --name $DOCKER_IMAGE $DOCKER_IMAGE serve --dev-addr=0.0.0.0:8000"
            DOCKER_PID=`docker run -v  ${PWD}/$MKDOC_PROJECT:$MKDOCS_DOCKER_WORKDIR -it -d --rm  -p $DOCKER_PORT:8000  --name $DOCKER_IMAGE  $DOCKER_IMAGE serve --dev-addr=0.0.0.0:8000`
            if [[ $? != 0 ]]; then
              echo "[ ERROR ]: Error serving MkDocs Container."
              exit 1
            fi  
            echo "[ INFO ]: Docker process $DOCKER_PID launched."
            echo "[ INFO ]: Project Successfully $LC_COMMAND."
            ;;
esac
