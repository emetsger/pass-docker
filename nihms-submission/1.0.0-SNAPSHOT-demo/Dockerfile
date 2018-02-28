FROM python:2.7.14-alpine3.6

ARG SUBMISSION_GIT_REPO
ENV SUBMISSION_GIT_REPO ${SUBMISSION_GIT_REPO:-https://github.com/OA-PASS/nihms-submission}

ARG SUBMISSION_GIT_BRANCH
ENV SUBMISSION_GIT_BRANCH ${SUBMISSION_GIT_BRANCH:-master}

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.7/community' >> /etc/apk/repositories && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/v3.7/main'      >> /etc/apk/repositories && \
    apk update && \
    apk add git=2.15.0-r1 && \
    apk add maven=3.5.2-r0 && \
    apk add openjdk8=8.151.12-r0 && \
    apk add curl && \
    apk add net-tools && \
    mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    git clone ${SUBMISSION_GIT_REPO} && \
    cd nihms-submission && \
    git checkout ${SUBMISSION_GIT_BRANCH} && \
    mvn package -DskipTests -Dcheckstyle.skip -Djavadoc.skip && \
    rm -rf ~/.m2 && \
    rm -rf /var/cache/apk/

ENV LOCAL_FTP_SERVER ftpserver

ENV FTP_SUBMISSION_DEBUG_PORT 5005

EXPOSE 80

ADD cgi_server.py /usr/local/http-cgi-server/

ENTRYPOINT exec python /usr/local/http-cgi-server/cgi_server.py

