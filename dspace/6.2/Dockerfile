FROM jetty:9.4.7-jre8-alpine

ARG DSPACE_BUILD_DIR=/dspace-build
ARG DSPACE_INSTALL_DIR=/dspace
ARG DSPACE_USER=jetty
ARG DSPACE_GIT_REPO=${DSPACE_GIT_REPO:-https://github.com/DSpace/DSpace}
ARG DSPACE_GIT_BRANCH=${DSPACE_GIT_BRANCH:-dspace-6.2}

ENV DSPACE_HOST=${DSPACE_HOST:-localhost} \
    DSPACE_PORT=${DSPACE_PORT:-8181} \
    DSPACE_DB_HOST=${DSPACE_DB_HOST:-postgres} \
    POSTGRES_DB_PORT=${POSTGRES_DB_PORT:-5432} \
    DSPACE_DB_NAME=${DSPACE_DB_NAME:-dspace} \
    DSPACE_DB_USER=${DSPACE_DB_USER:-dspace} \
    DSPACE_DB_PASS=${DSPACE_DB_PASS:-""} \
    DSPACE_INSTALL_DIR=${DSPACE_INSTALL_DIR:-/dspace}

USER root

RUN mkdir ${DSPACE_BUILD_DIR} && \
    cd ${DSPACE_BUILD_DIR} && \
    apk --update --no-cache add \
            openjdk8 \
            maven \
            git \
            apache-ant \
            postgresql-client && \
    git clone ${DSPACE_GIT_REPO}  && \
    cd `basename ${DSPACE_GIT_REPO}` && \
    git checkout -b ${DSPACE_GIT_BRANCH} ${DSPACE_GIT_BRANCH} && \
    mvn package && \
    cd dspace/target/dspace-installer && \
    sed -e "s:^[ ]*depends=\"init_installation,init_configs,test_database,install_code\":depends=\"init_installation,init_configs,install_code\":" -i build.xml && \
    ant fresh_install && \
    grep ${DSPACE_USER} /etc/passwd || adduser -D ${DSPACE_USER} ; \
    mkdir -p ${DSPACE_INSTALL_DIR} && \
    cp -r ${DSPACE_INSTALL_DIR}/webapps/xmlui/ /var/lib/jetty/webapps && \
    cp -r ${DSPACE_INSTALL_DIR}/webapps/swordv2/ /var/lib/jetty/webapps && \
    chown -R ${DSPACE_USER} ${DSPACE_INSTALL_DIR} && \
    chown -R jetty /var/lib/jetty/webapps/* && \
    cd / && \
    rm -rf ${DSPACE_BUILD_DIR} && \
    apk del maven \
        apache-ant \
        openjdk8 \
        git && \
    rm -rf /var/cache/apk && \
    rm -rf ~/.m2

ADD wait-and-init-db.sh /wait-and-init-db.sh

ADD import.xml /import.xml

RUN chown jetty /wait-and-init-db.sh && chmod 550 /wait-and-init-db.sh && chown ${DSPACE_USER} /import.xml

USER jetty

WORKDIR /var/lib/jetty

CMD ["/wait-and-init-db.sh"]

EXPOSE ${DSPACE_PORT}