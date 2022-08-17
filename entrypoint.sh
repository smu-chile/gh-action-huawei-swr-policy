#!/bin/bash
set -e

function main() {
  
   
  sanitize "${INPUT_ACCESS_KEY_ID}" "access_key_id"
  sanitize "${INPUT_SECRET_ACCESS_KEY}" "secret_access_key"
  sanitize "${INPUT_REGION}" "region"
  sanitize "${INPUT_REPO}" "repo"
  sanitize "${INPUT_SWR_REGISTRY}" "swr_registry"
  sanitize "${INPUT_HUAWEI_USER}" "huawei_user"
  sanitize "${INPUT_HUAWEI_PASSWORD}" "huawei_password"
  sanitize "${INPUT_HUAWEI_DOMAIN}" "huawei_domain"
  sanitize "${INPUT_ENPOINT_TOKEN}" "enpoint_token"
  sanitize "${INPUT_ENPOINT_SWR}" "enpoint_swr"
  sanitize "${INPUT_SWR_NAMESPACE}" "swr_namespace"
  sanitize "${INPUT_SWR_REPOS}" "swr_repos"

   
  
  check_behavior_mode
  huawei_configure
  login
  docker_build
  docker_tag
  create_token
  check_swr_policy
  create_swr_policy
  
  
  if [ $INPUT_BEHAVIOR == "build" ] ; then 
    run_pre_build_script $INPUT_PREBUILD_SCRIPT
    docker_build $INPUT_TAGS $INPUT_SWR_REGISTRY
  else
    docker_tag $INPUT_TAGS $INPUT_SWR_REGISTRY
  fi;
  docker_push_to_swr $INPUT_TAGS $INPUT_SWR_REGISTRY
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
  export HUAWEI_LOGIN=$(printf "${INPUT_ACCESS_KEY_ID}" | openssl dgst -binary -sha256 -hmac "${INPUT_SECRET_ACCESS_KEY}" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//')

}

function login() {
  echo "== START LOGIN"
  export LOGIN_COMMAND=$(docker login -u $HUAWEI_DEFAULT_REGION@$HUAWEI_ACCESS_KEY_ID -p  $HUAWEI_LOGIN ${INPUT_SWR_REGISTRY})
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


function create_token() {
  echo "== START CREATE TOKEN TO AUTENTICATE SWR"
  export HUAWEI_USER=${INPUT_HUAWEI_USER}
  export HUAWEI_PASSWORD=${INPUT_HUAWEI_PASSWORD}
  export HUAWEI_DOMAIN=${INPUT_HUAWEI_DOMAIN}
  export HUAWEI_TOKEN=$(curl -s -ik -X POST -H 'Content-Type=application/json;charset=utf8'  \
  -d '{"auth": {"identity": {"methods": ["password"],"password": {"user": {"domain": {"name": "'"$HUAWEI_DOMAIN"'"},"name": "'"$HUAWEI_USER"'","password": "'"$HUAWEI_PASSWORD"'"}},},"scope": {"domain": {"name": "'"$HUAWEI_DOMAIN"'"}}}}'  \
  https://${INPUT_ENPOINT_TOKEN}/v3/auth/tokens\?nocatalog\=true |grep X-Subject-Token | sed 's/X-Subject-Token: //')
  echo "== FINISHED CREATE TOKEN"

}


function check_swr_policy() {
  echo "== START CHECK POLICY TO SWR"
  export SWR_POLICY=$(curl --location --request GET https://${INPUT_ENPOINT_SWR}/v2/manage/namespaces/${INPUT_SWR_NAMESPACE}/repos/${INPUT_SWR_REPOS}/retentions \
--header 'Content-Type: application/json;charset=utf8' \
--header "X-Auth-Token: $HUAWEI_TOKEN" |cut -c 3-9)
  echo $SWR_POLICY
  echo "== FINISHED CHECK POLICY TO SWR"
}

function create_swr_policy() {
  echo "== START CREATE POLICY TO SWR"
  
  if [ -z "$SWR_POLICY" ]; then 
  curl --location --request POST https://${INPUT_ENPOINT_SWR}/v2/manage/namespaces/${INPUT_SWR_NAMESPACE}/repos/${INPUT_SWR_REPOS}/retentions \
--header 'Content-Type: application/json;charset=utf8' \
--header "X-Auth-Token: $HUAWEI_TOKEN" \
--data-raw '{
    "algorithm": "or",
    "rules": [
        {
            "template": "date_rule",
            "params": {
                "num": "5"
            },
            "tag_selectors": [
                {
                    "kind": "label",
                    "pattern": "v3"
                },
                {
                    "kind": "regexp",
                    "pattern": "prod-*"
                }
            ],
            
        }
    ]
}'
  echo "== FINISHED CREATE POLICY"

  else     
  echo "THERE IS ALREADY A POLICY IS $SWR_POLICY"  
fi
}

main
