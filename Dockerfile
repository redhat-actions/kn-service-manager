FROM registry.access.redhat.com/ubi8/ubi-minimal:8.2

ENV OC_VERSION=4.6.17
ENV KN_VERSION=0.19.1

RUN microdnf install -y gzip tar curl
RUN curl -sSLf \
    "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/serverless/${KN_VERSION}/kn-linux-amd64-${KN_VERSION}.tar.gz" | \
    tar --exclude="LICENSE" -C /usr/local/bin -zxv -f - \
    && chmod +x /usr/local/bin/kn && \
    curl -sSLf "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz" | \
    tar --exclude='README.md' -C /usr/local/bin -zxv -f - \
    && chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
