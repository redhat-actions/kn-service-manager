# Knative Service Deploy

[![CI Checks](https://github.com/redhat-actions/kn-service-deploy/workflows/CI%20Checks/badge.svg)](https://github.com/redhat-actions/kn-service-deploy/actions?query=workflow%3A%22CI+Checks%22)
[![App Build and Push](https://github.com/redhat-actions/kn-service-deploy/workflows/App%20Build%20and%20Push/badge.svg)](https://github.com/redhat-actions/kn-service-deploy/actions?query=workflow%3A%22App+Build+and+Push%22)
<br></br>
[![tag badge](https://img.shields.io/github/v/tag/redhat-actions/kn-service-deploy)](https://github.com/redhat-actions/kn-service-deploy/tags)
[![license badge](https://img.shields.io/github/license/redhat-actions/kn-service-deploy)](./LICENSE)

GitHub Action to deploy [Knative Service](https://kn.dev) using [Knative Client](https://github.com/knative/client).

## Pre-requisites

Kubernetes Cluster with Knative, if you dont have an OpenShift cluster see [try.openshift.com](https://try.openshift.com) or try our new [Developer Sandbox](https://developers.redhat.com/developer-sandbox).

## Action Inputs

<table>
  <thead>
    <tr>
      <th>Input</th>
      <th>Required</th>
      <th>Description</th>
    </tr>
  </thead>

  <tr>
    <td>command</td>
    <td>No</td>
    <td>The `kn` service command, accepted commands are <code>create</code>, <code>update</code>, <code>apply</code> and <code>delete</code>.
    Defaults to <code>create</code>.</td>
  </tr>

  <tr>
    <td>container_image</td>
    <td>No</td>
    <td>The container image to use for the service. Not required if <code>service_operation</code> is set to <code>delete</code>. </td>
  </tr>

  <tr>
    <td>force_create</td>
    <td>No</td>
    <td>"Pass <code>--force</code> to <code>kn create</code>. If the service already exists,
    the service will be replaced, instead of kn create failing.
    This input has no effect if <code>command</code> is not <code>create</code>. Defaults to <code>false</code>.
    </td>
  </tr>

  <tr>
    <td>kn_extra_args</td>
    <td>No</td>
    <td>Any extra arguments to append to the <code>kn 'command'</code> call. </td>
  </tr>

  <tr>
    <td>namespace</td>
     <td>No</td>
    <td>The Kubernetes Namespace to deploy to. Defaults to current context's namespace. </td>
  </tr>

  <tr>
    <td>registry_password</td>
    <td>No</td>
    <td>The registry user password or token. Required if image registry is private. </td>
  </tr>

  <tr>
    <td>registry_user</td>
    <td>No</td>
    <td>The registry user to use to create the image pull secret. Required if image registry is private. </td>
  </tr>

  <tr>
    <td>service_name</td>
    <td>Yes</td>
    <td>
      The Knative Service name.
    </td>
  </tr>

</table>

## Action Outputs

<table>
  <thead>
    <tr>
      <th>Output</th>
      <th>Description</th>
    </tr>
  </thead>

  <tr>
    <td>service_url</td>
    <td>
      Knative Service URL of the service created.
      Will be empty if <code>command</code> input is set to <code>delete</code>
    </td>
  </tr>

</table>

**NOTE:**
When username and password or token is provided to pull the image, then the action will create a Kubernetes Secret of type `docker-registry` with the `docker-username` to be `registry_user` and `docker-password` to be `registry_password`. The `docker-server` value will be the first part of the `container_image` value.


## Passing extra service arguments

This action provides basic options such as namespace, service name, image and command to be configured. There might be cases where you might want to pass extra arguments to the `kn service <command>`, in those cases you can use `kn_extra_args` as shown:

Consider an example that you want to add `--max-scale=5` and `--min-scale=1`, then your action snippet will be:

```yaml
- name: Knative Service Deploy
  id: kn_service_deploy
  uses: redhat-actions/kn-service-deploy@v1
  with:
    service_name: getting-started-knative
    container_image: "${{ steps.push-tag-to-quay.outputs.registry-path }}"
    kn_extra_args: >
      --max-scale=5
      --min-scale=1
```

## Example

The example below shows how the `kn-service-deploy` action can be used to deploy knative service using openshift cluster.

Here OpenShift is used as the Kubernetes platform, you can use the [oc-login action](https://github.com/redhat-actions/oc-login), to login into the OpenShift cluster to perform `kn` actions.

```yaml
# Login into the Openshift cluster
# with your username and password/token
- name: Authenticate and set context
  id: oc_login
  uses: redhat-actions/oc-login@v1
  with:
    openshift_server_url: ${{ secrets.OPENSHIFT_SERVER }}
    openshift_token: ${{ secrets.OPENSHIFT_TOKEN }}
    insecure_skip_tls_verify: true
    namespace: ${{ env.NAMESPACE }}

# Deploy knative service using container image
- name: Knative Service Deploy
  id: kn_service_deploy
  uses: redhat-actions/kn-service-deploy@v1
  with:
    service_name: getting-started-knative
    container_image: "${{ env.IMAGE_NAME }}"
```

For a complete example see [the example workflow](./.github/workflows/example.yml).
