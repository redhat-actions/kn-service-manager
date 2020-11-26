#!/usr/bin/env bash

set -e 
set -o pipefail 

#TODO combine with space seperation
echo "$INPUT_SERVICE_PARAMS"

#TODO how to login to kube servers??
#TODO allow secure sigin

if [[ -n "$INPUT_OPENSHIFT_TOKEN" ]];
then
  echo "Using OpenShfit Token to login"
  oc login --token="$INPUT_OPENSHIFT_TOKEN" \
    "$INPUT_K8S_API_SERVER_URL"
else 
  echo "Using OpenShfit Username and Password to login"
  oc login --username="$INPUT_OPENSHIFT_USERNAME" \
     --password="$INPUT_OPENSHIFT_PASSWORD" \
     --insecure-skip-tls-verify \
     "$INPUT_K8S_API_SERVER_URL"
fi

echo "Creating Knative Service $INPUT_SERVICE_NAME"
kn service "$INPUT_SERVICE_OPERATION" "$INPUT_SERVICE_NAME" \
   --namespace="$INPUT_SERVICE_NAMESPACE" \
   --insecure-skip-tls-verify \
   --image="$INPUT_CONTAINER_IMAGE"

# Set the output 
service_info=$(kn service describe --namespace="$INPUT_SERVICE_NAMESPACE" "$INPUT_SERVICE_NAME")
echo "::set-output name=service_info::$service_info"