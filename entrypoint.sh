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

if [[ -n $INPUT_NAMESPACE ]]; then
    echo "Setting service namespace to '$INPUT_NAMESPACE'"
    namespace_arg="--namespace=$INPUT_NAMESPACE"
else
    echo "No namespace provided"
fi

#################################################
##
#################################################

# Delete kn service if service command is set to 'delete'
if [[ $INPUT_COMMAND == "delete" ]];
then
  appendParams "delete"
  appendParams "$INPUT_SERVICE_NAME"
  echo "⏳ Running: ${kn_command[*]} "
  echo "🗑️ Deleting $INPUT_SERVICE_NAME service"
  ${kn_command[*]}
  echo "✅ $INPUT_SERVICE_NAME service successfully deleted"
  exit 0
fi

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

appendParams "$INPUT_COMMAND"
appendParams "$INPUT_SERVICE_NAME"
appendParams $namespace_arg

case $INPUT_COMMAND in
  create | update | apply )
    appendParams "--image=$INPUT_CONTAINER_IMAGE"
    [[ "$is_private_registry" != "false" ]] \
    && appendParams "--pull-secret=$secret_name"
   ;;
  *)
   printf "❌ %s is not a valid kn service command" "$INPUT_COMMAND"
  ;;
esac

# Add force flag in create command
[[ "$INPUT_COMMAND" == "create" ]] && [[ "$INPUT_FORCE_CREATE" != "false" ]] \
    && appendParams "--force"

# Add an extra parameters to the service
OLDIFS=$IFS
if [[ -n $INPUT_KN_EXTRA_ARGS ]]
then
  IFS=$'\n'
  kn_command+=("${INPUT_KN_EXTRA_ARGS}")
  IFS=$OLDIFS
fi

echo "⏳ Running: ${kn_command[*]} "
${kn_command[*]}

# After successful service creation extract the service url
# and set that as output to the action
echo "✅ $INPUT_SERVICE_NAME service created successfully."
service_url=$(kn service describe $namespace_arg "$INPUT_SERVICE_NAME" -o url)
echo "::set-output name=service_url::$service_url"
