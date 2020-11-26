#!/usr/bin/env bash

set -e 
set -o pipefail 

#TODO combine with space seperation
echo "$SERVICE_PARAMS"

#TODO how to login to kube servers??

if [[ -n "$OPENSHIFT_TOKEN" ]];
then
  echo "Using OpenShfit Token to login"
  oc login --token="$OPENSHIFT_TOKEN" "$K8S_API_SERVER_URL"
else 
  echo "Using OpenShfit Username and Password to login"
  oc login --username="$OPENSHIFT_USERNAME" \
     --password="$OPENSHIFT_PASSWORD"
    "$K8S_API_SERVER_URL"
fi

echo "Creating Knative Service $SERVICE_NAME"
kn service "$SERVICE_OPERATION" "$SERVICE_NAME" \
   --namespace="$SERVICE_NAMESPACE" \
   --image="$CONTAINER_IMAGE"

# Set the output 
service_info=$(kn service describe --namespace="$SERVICE_NAMESPACE" "$SERVICE_NAME")
echo "::set-output name=service_info::$service_info"