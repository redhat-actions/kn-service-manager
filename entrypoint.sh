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

namespace_arg=""

if [[ -n $INPUT_SERVICE_NAMESPACE ]]; then
    echo "Setting service namespace to '$INPUT_SERVICE_NAMESPACE'"
    namespace_arg="--namespace=$INPUT_SERVICE_NAMESPACE"
else
    echo "No namespace provided"
fi

#################################################
##
#################################################
docker_server="${INPUT_CONTAINER_IMAGE%/*/*}"
secret_name="$docker_server.pull-secret"
is_private_registry=false
if [[ $INPUT_REGISTRY_USER != "" ]] && [[ $INPUT_REGISTRY_PASSWORD != "" ]];
then
 # delete the old secret if exist, that ensures 
 # new values are updated during each run
 oc delete secret $namespace_arg "$secret_name" || true
 # create docker registry secret to allow pull
 # from private container registry 
 oc create secret docker-registry "$secret_name" \
   $namespace_arg \
   --docker-username="$INPUT_REGISTRY_USER" \
   --docker-password="$INPUT_REGISTRY_PASSWORD" \
   --docker-server="$docker_server"
  is_private_registry=true
fi

appendParams "$INPUT_SERVICE_OPERATION"
appendParams "$INPUT_SERVICE_NAME"
appendParams $namespace_arg

case $INPUT_SERVICE_OPERATION in
  create | update | apply )
    appendParams "--image=$INPUT_CONTAINER_IMAGE"
    [[ "$is_private_registry" != "false" ]] \
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
service_url=$(kn service describe $namespace_arg "$INPUT_SERVICE_NAME" -o url)
echo "::set-output name=service_url::$service_url"