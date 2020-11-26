#!/usr/bin/env bash

set -e 
set -o pipefail 

##########################
##
##########################
function appendParams(){
   kn_command+=("$1")
}

INPUT_PRIVATE_REGISTRY="true"
INPUT_K8S_API_SERVER_URL=$(oc whoami --show-server)
INPUT_OPENSHIFT_TOKEN=$(oc whoami -t)
INPUT_CONTAINER_IMAGE='quay.io/kameshsampath/fruits-app:master'
INPUT_SERVICE_NAME='fun'
INPUT_SERVICE_NAMESPACE='test'
INPUT_REGISTRY_USER="$QUAYIO_USERNAME"
INPUT_REGISTRY_PASSWORD="$QUAYIO_PASSWORD"
INPUT_SERVICE_OPERATION='create'

kn_command=("kn" "service")

INPUT_SERVICE_PARAMS=$1

#TODO how to login to kube servers??
#TODO allow secure sigin

if [[ -n "$INPUT_OPENSHIFT_TOKEN" ]];
then
  echo "Using OpenShfit Token to login"
  oc login --insecure-skip-tls-verify "$INPUT_K8S_API_SERVER_URL" \
    --token="$INPUT_OPENSHIFT_TOKEN"
else 
  echo "Using OpenShfit Username and Password to login"
  oc login --insecure-skip-tls-verify "$INPUT_K8S_API_SERVER_URL" \
     --username="$INPUT_OPENSHIFT_USERNAME" \
     --password="$INPUT_OPENSHIFT_PASSWORD"
fi

registry_server="${INPUT_CONTAINER_IMAGE%/*/*}"
secret_name="$registry_server.pull-secret"
is_private_registry=false
if [[ $INPUT_PRIVATE_REGISTRY == "yes" ]] || [[ $INPUT.PRIVATE_REGISTRY == "true" ]];
then
 oc delete secret "$secret_name" || true
 oc create secret docker-registry "$secret_name" \
   --namespace="$INPUT_SERVICE_NAMESPACE" \
   --docker-username="$INPUT_REGISTRY_USER" \
   --docker-password="$INPUT_REGISTRY_PASSWORD" \
   --docker-server="$registry_server"
  is_private_registry=true
fi

appendParams "$INPUT_SERVICE_OPERATION"
appendParams "$INPUT_SERVICE_NAME"
appendParams "--namespace=$INPUT_SERVICE_NAMESPACE"

case $INPUT_SERVICE_OPERATION in
  create | update | apply )
    appendParams "--image=$INPUT_CONTAINER_IMAGE"
    [[ $is_private_registry ]] \
    && appendParams "--pull-secret=$secret_name"
   ;;
  *)
   printf "%s is not a valid kn service command" "$INPUT_SERVICE_OPERATION"
  ;;
esac

OLDIFS=$IFS
if [[ -n $INPUT_SERVICE_PARAMS ]];
then
  IFS=$'\n'
  kn_command+=("${INPUT_SERVICE_PARAMS}")
  IFS=$OLDIFS
fi
echo "Running: ${kn_command[*]} "
${kn_command[*]}

# Set the output 
service_url=$(kn service describe --namespace="$INPUT_SERVICE_NAMESPACE" "$INPUT_SERVICE_NAME" -o url)
echo "::set-output name=service_url::$service_url"

http "$service_url/api/fruit"

# # clean up
kn service delete "$INPUT_SERVICE_NAME" \
      --namespace="$INPUT_SERVICE_NAMESPACE"