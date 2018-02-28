FROM alpine:3.7

ARG EMBER_GIT_REPO
ARG EMBER_GIT_BRANCH

ENV EMBER_GIT_BRANCH=${EMBER_GIT_BRANCH:-master} \
    EMBER_GIT_REPO=${EMBER_GIT_REPO:-https://github.com/OA-PASS/pass-ember} \
    EMBER_BUILD_DIR=/ember

COPY bin/entrypoint.sh /bin

RUN apk add --no-cache nodejs-npm && \
    apk add --no-cache --virtual .build-deps git && \
    mkdir -p ${EMBER_BUILD_DIR} && \
    cd ${EMBER_BUILD_DIR} && \
    git clone ${EMBER_GIT_REPO} . && \
    git checkout ${EMBER_GIT_BRANCH} && \
    chmod 700 /bin/entrypoint.sh && \
    npm install && \
    npm install -g ember-cli

WORKDIR /ember

ENTRYPOINT [ "/bin/entrypoint.sh" ]