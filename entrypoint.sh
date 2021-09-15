#!/bin/bash
set -e

function main() {
  
  sanitize "${INPUT_ACCESS_KEY_ID}" "access_key_id"
  sanitize "${INPUT_SECRET_ACCESS_KEY}" "secret_access_key"
  sanitize "${INPUT_REGION}" "region"
  sanitize "${INPUT_REPO}" "repo"
  sanitize "${INPUT_SWR_REGISTRY}" "swr_registry"
  sanitize "${INPUT_BEHAVIOR}" "behavior"

  shopt -s nocasematch;
  
  check_behavior_mode
  huawei_configure
  login
  docker_build
  docker_tag
  
  
  if [ $INPUT_BEHAVIOR == "build" ] ; then 
    run_pre_build_script $INPUT_PREBUILD_SCRIPT
    docker_build $INPUT_TAGS $INPUT_SWR_REGISTRY
  else
    docker_tag $INPUT_TAGS $INPUT_SWR_REGISTRY
  fi;
  docker_push_to_swr$INPUT_TAGS $INPUT_SWR_REGISTRY
}

function check_behavior_mode() {
  if [ $INPUT_BEHAVIOR == "upload" ] ; then  
    if [ -z "$INPUT_IMAGE_NAME" ]; then 
      echo "======> If behavior is set to upload, you must specify the image name"
      exit 1 
    fi;
  fi;
} 


function sanitize() {
  if [ -z "${1}" ]; then
    >&2 echo "Unable to find the ${2}. Did you set with.${2}?"
    exit 1
  fi
}

function huawei_configure() {
  export HUAWEI_ACCESS_KEY_ID=${INPUT_ACCESS_KEY_ID}
  export HUAWEI_SECRET_ACCESS_KEY=${INPUT_SECRET_ACCESS_KEY}
  export HUAWEI_DEFAULT_REGION=${INPUT_REGION}
  export HUAWEI_LOGIN=$(printf "$access_key_id" | openssl dgst -binary -sha256 -hmac "$secret_access_key" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//')

}

function login() {
  echo "== START LOGIN"
  export LOGIN_COMMAND=$(docker login -u $HUAWEI_DEFAULT_REGION@$HUAWEI_ACCESS_KEY_ID -p  $HUAWEI_LOGIN $HUAWEI_REGISTRY)
  echo $LOGIN_COMMAND
  echo "== FINISHED LOGIN"
}

function docker_build() {
  echo "== START DOCKERIZE"
  local TAG=$1
  local docker_tag_args=""
  local DOCKER_TAGS=$(echo "$TAG" | tr "," "\n")
  for tag in $DOCKER_TAGS; do
    docker_tag_args="$docker_tag_args -t $2/$INPUT_REPO:$tag"
  done

  docker build $INPUT_EXTRA_BUILD_ARGS -f $INPUT_DOCKERFILE $docker_tag_args $INPUT_PATH
  echo "== FINISHED DOCKERIZE"
}

function docker_tag() {
  echo "== START IMAGE TAG"

  local TAG=$1
  local docker_tag_args=""
  local DOCKER_TAGS=$(echo "$TAG" | tr "," "\n")
  for tag in $DOCKER_TAGS; do
    docker image tag $INPUT_IMAGE_NAME $2/$INPUT_REPO:$tag
  done
   
  echo "== FINISH IMAGE TAG"
}

function docker_push_to_swr() {
  echo "== START PUSH TO SWR"
  local TAG=$1
  local DOCKER_TAGS=$(echo "$TAG" | tr "," "\n")
  
  for tag in $DOCKER_TAGS; do
    docker push $2/$INPUT_REPO:$tag
    echo ::set-output name=image::$2/$INPUT_REPO:$tag
  done
  echo "== FINISHED PUSH TO SWR"
}

main
