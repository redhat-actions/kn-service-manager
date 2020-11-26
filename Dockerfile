FROM registry.access.redhat.com/ubi8/ubi-minimal:8.2

ENV OPENSHIFT_VERSION=4.6.4
ENV KNATIVE_CLIENT_VERSION=v0.17.4

RUN microdnf install -y shadow-utils tar wget curl \
    && wget -O/usr/local/bin/kn https://github.com/knative/client/releases/download/${KNATIVE_CLIENT_VERSION}/kn-linux-amd64 \
    && tar --exclude='README.md' -C /usr/local/bin -zxf https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-$OPENSHIFT_VERSION}.tar.gz \
    && chmod +x /usr/local/bin/kn \
    && chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
