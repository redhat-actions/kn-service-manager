#!/usr/bin/env bash

set -e 
set -o pipefail 

##############################################################
## appendParams appends params to the kn service 
##############################################################
function appendParams(){
   kn_command+=("$1")
}

kn_command=("kn" "service")

if [[ -n "$INPUT_OPENSHIFT_TOKEN" ]];
then
  echo "Using OpenShfit Token to login"
  oc login --insecure-skip-tls-verify "$INPUT_K8S_API_SERVER_URL" \
    --token="$INPUT_OPENSHIFT_TOKEN"
elif [[ -n $INPUT_OPENSHIFT_USERNAME ]] && [[ -n $INPUT_OPENSHIFT_PASSWORD ]];
then
  echo "Using OpenShfit Username and Password to login"
  oc login --insecure-skip-tls-verify "$INPUT_K8S_API_SERVER_URL" \
     --username="$INPUT_OPENSHIFT_USERNAME" \
     --password="$INPUT_OPENSHIFT_PASSWORD"
else
  #TODO Ability to log into kube cluster
  echo "Login to the Kube Cluster"
fi

#################################################
##
#################################################
registry_server="${INPUT_CONTAINER_IMAGE%/*/*}"
secret_name="$registry_server.pull-secret"
is_private_registry=false
if [[ $INPUT_PRIVATE_REGISTRY == "yes" ]] || [[ $INPUT.PRIVATE_REGISTRY == "true" ]];
then
 # delete the old secret if exist, that ensures 
 # new values are updated during each run
 kubectl delete secret --namespace="$INPUT_SERVICE_NAMESPACE" "$secret_name" || true
 # create docker registry secret to allow pull
 # from private container registry 
 kubectl create secret docker-registry "$secret_name" \
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

# Add an extra parameters to the service
OLDIFS=$IFS
if [[ -n $INPUT_SERVICE_PARAMS ]];
then
  IFS=$'\n'
  kn_command+=("${INPUT_SERVICE_PARAMS}")
  IFS=$OLDIFS
fi

echo "Running: ${kn_command[*]} "
${kn_command[*]}

# After successful service creation extract the service url 
# and set that as output to the action
service_url=$(kn service describe --namespace="$INPUT_SERVICE_NAMESPACE" "$INPUT_SERVICE_NAME" -o url)
echo "::set-output name=service_url::$service_url"