#!/bin/bash

function k::test-echo {
  echo "TEST"
}

function k::get-name {
  PROJECT=${PWD##*/} #override here is project name is not the same as repo name
}

function k::check-exists {
  [[ -n $1 ]] || {
    echo "Internal error. FILENAME not specified in k::check-exists." 1>&2
    return 2
  }
  ~/google-cloud-sdk/bin/kubectl describe -f $1
}

# create if not exists
function k::create {
  [[ -n $1 ]] || {
    echo "Internal error. TYPE not specified in k::create." 1>&2
    return 2
  }
  FILENAME=$1.yaml
  if k::check-exists $FILENAME
  then echo "$FILENAME already exists"
  else ~/google-cloud-sdk/bin/kubectl create -f $FILENAME
  fi
}

# delete and create if already exists
function k::override {
  [[ -n $1 ]] || {
    echo "Internal error. TYPE not specified in k::override." 1>&2
    return 2
  }
  FILENAME=$1.yaml
  if k::check-exists $FILENAME
  then ~/google-cloud-sdk/bin/kubectl delete -f $FILENAME
  fi
  ~/google-cloud-sdk/bin/kubectl create -f $FILENAME
}

# create if not exists, upgrade if exists
function k::upgrade {
  RC_FILENAME=rc.yaml
  SERVICE_FILENAME=service.yaml
  if k::check-exists $RC_FILENAME
  then
  echo "$RC_FILENAME already exists"
  ~/google-cloud-sdk/bin/kubectl rolling-update $PROJECT --image=$DOCKER_REPO/$PROJECT:$CI_BUILD_TAG
  else ~/google-cloud-sdk/bin/kubectl create -f $RC_FILENAME
  fi
  if [ -f ./$SERVICE_FILENAME ]; then
    k::override service
  fi
 }

 function k::build {
  /usr/bin/docker build -t $DOCKER_REPO/$PROJECT .
  ID="$(/usr/bin/docker images | grep $DOCKER_REPO'/'$PROJECT | head -n 1 | awk '{print $3}')"
  /usr/bin/docker tag $ID $DOCKER_REPO/$PROJECT:$CI_BUILD_TAG
  /usr/bin/docker push $DOCKER_REPO/$PROJECT
 }

 function k::delete {
  LAST_DEPLOYED_RC="$(~/google-cloud-sdk/bin/kubectl get rc | grep $PROJECT:$CI_BUILD_TAG | /usr/bin/tail -n 1 | /usr/bin/awk '{print $1}')"
  ~/google-cloud-sdk/bin/kubectl delete rc $LAST_DEPLOYED_RC
 }