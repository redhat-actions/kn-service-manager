FROM registry.access.redhat.com/ubi8/ubi-minimal:8.2

ENV OPENSHIFT_VERSION=4.6
ENV KNATIVE_CLIENT_VERSION=v0.20.0

RUN microdnf install -y gzip tar curl \
    && curl -o/usr/local/bin/kn -sSL "https://github.com/knative/client/releases/download/${KNATIVE_CLIENT_VERSION}/kn-linux-amd64" \
    && curl -sSL "https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OPENSHIFT_VERSION}/linux/oc.tar.gz" | \
      tar --exclude='README.md' -C /usr/local/bin -zxf - \
    && chmod +x /usr/local/bin/kn \
    && chmod +x /usr/local/bin/oc /usr/local/bin/kubectl

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
