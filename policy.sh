#!/bin/bash
function main() {

create_token
check_swr_policy
create_swr_policy


}
function create_token() {
  echo "== START CREATE TOKEN TO AUTENTICATE SWR"
  export HUAWEI_USER=${INPUT_HUAWEI_USER}
  export HUAWEI_PASSWORD=${INPUT_HUAWEI_PASSWORD}
  export HUAWEI_DOMAIN=${INPUT_HUAWEI_DOMAIN}
  export HUAWEI_TOKEN=$(curl -s -ik -X POST -H 'Content-Type=application/json;charset=utf8'  \
  -d '{"auth": {"identity": {"methods": ["password"],"password": {"user": {"domain": {"name": "'"$HUAWEI_DOMAIN"'"},"name": "'"$HUAWEI_USER"'","password": "'"$HUAWEI_PASSWORD"'"}},},"scope": {"domain": {"name": "'"$HUAWEI_DOMAIN"'"}}}}'  \
  https://iam.myhuaweicloud.com/v3/auth/tokens\?nocatalog\=true |grep X-Subject-Token | sed 's/X-Subject-Token: //')
  echo "== FINISHED CREATE TOKEN"

}

function check_swr_policy() {
  echo "== START CHECK POLICY TO SWR"
  export SWR_POLICY=$(curl --location --request GET 'https://swr-api.la-south-2.myhuaweicloud.com/v2/manage/namespaces/smu-chile/repos/harness-poc/retentions' \
--header 'Content-Type: application/json;charset=utf8' \
--header "X-Auth-Token: $HUAWEI_TOKEN" |cut -c 3-9)
  echo $SWR_POLICY
  echo "== FINISHED CHECK POLICY TO SWR"
}

function create_swr_policy() {
  echo "== START CREATE POLICY TO SWR"
  
  if [ -z "$SWR_POLICY" ]; then 
  curl --location --request POST 'https://swr-api.la-south-2.myhuaweicloud.com/v2/manage/namespaces/smu-chile/repos/harness-poc/retentions' \
--header 'Content-Type: application/json;charset=utf8' \
--header "X-Auth-Token: $HUAWEI_TOKEN" \
--data-raw '{
    "algorithm": "or",
    "rules": [
        {
            "params": {
                "num": "5"
            },
            "tag_selectors": [
                {
                    "kind": "label",
                    "pattern": "v5"
                }
            ],
            "template": "tag_rule"
        }
    ]
}'
  echo "== FINISHED CREATE POLICY"

  else     
  echo "THERE IS ALREADY A POLICY IS $SWR_POLICY"  
fi
}



main