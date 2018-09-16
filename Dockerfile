FROM alpine:3.6

ARG KUBE_VERSION=1.9.4
ARG MINIKUBE_VERSION=0.27.0

ENV GOPATH="/usr/bin" \
    GOROOT="/usr/lib/go" \
    KUBERNETES_VERSION="${KUBE_VERSION}" \
    MINIKUBE_WANTUPDATENOTIFICATION="false" \
    MINIKUBE_WANTREPORTERRORPROMPT="false" \
    MINIKUBE_HOME="$HOME" \
    CHANGE_MINIKUBE_NONE_USER="true"

RUN apk --update --no-cache add docker sudo bash openrc && \
    apk upgrade --update && \
    apk add --no-cache --virtual=.build-dependencies ca-certificates python2 wget go make autoconf findutils make pkgconf libtool g++ automake linux-headers git && \
    wget "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl" -O "/usr/local/bin/kubectl" && \
    chmod +x /usr/local/bin/kubectl && \
    mkdir -p /usr/bin/src/k8s.io && \
    cd /usr/bin/src/k8s.io && \
    git clone --depth=1 --branch v${MINIKUBE_VERSION} https://github.com/kubernetes/minikube && \
    cd minikube && \
    make && \
    mv ./out/minikube /usr/local/bin/minikube && \
    cd && rm -rf /tmp/* && \
    rm -rf /usr/bin/src/k8s.io && \
    apk del .build-dependencies && \
    rc-update add docker boot && \
    echo "export DOCKER_HOST='tcp://127.0.0.1:2375'" >> /etc/profile

COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME /root/.minikube

EXPOSE 2375 8443
ENTRYPOINT ["entrypoint.sh"]

