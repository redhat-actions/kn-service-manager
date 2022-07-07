{
  "packageManager": "python",
  "packageName": "ipyparallel",
  "uninstallInstructions": "Use your Python package manager (pip, conda, etc.) to uninstall the package ipyparallel"
}
 curl -sSLf \
    "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/serverless/${KN_VERSION}/kn-linux-amd64-${KN_VERSION}.tar.gz" | \
    tar --exclude="LICENSE" -C /usr/local/bin -zxv -f - \
    && chmod +x /usr/local/bin/kn && \
    curl -sSLf "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz" | \
    tar --exclude='README.md' -C /usr/local/bin -zxv -f - \
    && chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

{
  "packageManager": "python",
  "packageName": "ipyparallel",
  "uninstallInstructions": "Use your Python package manager (pip, conda, etc.) to uninstall the package ipyparallel"
}
