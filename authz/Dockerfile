FROM openjdk:8u212-jre-alpine3.9@sha256:5c5867cd2d4d198d1e53562c8202dfa388832b6f7d8276e69eae212b326c7777
ENV VERSION=0.4.5 \
    AUTHZ_MAX_ATTEMPTS=20 \
    PASS_BACKEND_ROLE=http://oapass.org/ns/roles/johnshopkins.edu#pass-backend \
    PASS_GRANTADMIN_ROLE=http://oapass.org/ns/roles/johnshopkins.edu#admin \
    PASS_SUBMITTER_ROLE=http://oapass.org/ns/roles/johnshopkins.edu#submitter


WORKDIR /app

ADD wait_and_start.sh /app

RUN apk add --no-cache ca-certificates wget gettext curl && \
    wget http://central.maven.org/maven2/org/dataconservancy/pass/pass-authz-listener/${VERSION}/pass-authz-listener-${VERSION}-exe.jar && \
    echo "6a9f87c97d090ea108112b2651d804d3da9572b6 *pass-authz-listener-${VERSION}-exe.jar" \
        | sha1sum -c -  && \
    rm -rf /var/cache/apk/ && \
    chmod 700 wait_and_start.sh && \
    echo "networkaddress.cache.ttl=10" >> ${JAVA_HOME}/lib/security/java.security

CMD ./wait_and_start.sh pass-authz-listener-${VERSION}-exe.jar
