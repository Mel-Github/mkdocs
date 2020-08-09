#!/bin/bash
STATUSCODE=$(curl --silent --output /dev/null --write-out "%{http_code}" "http://localhost:8000")
if [[ $STATUSCODE -ne 200 ]] ; then
    # error handling
  echo "Error"
  exit 1
else
  echo "ok"
  exit 0 
fi
