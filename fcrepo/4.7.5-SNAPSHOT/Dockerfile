FROM tomcat:8.5.24-jre8-alpine

ENV FCREPO_VERSION=4.7.5 \
FCREPO_HOST=fcrepo \
FCREPO_PORT=8080 \
FCREPO_JMS_PORT=61616 \
FCREPO_STOMP_PORT=61613 \
FCREPO_CONTEXT_PATH=/fcrepo \
FCREPO_LOG_LEVEL=INFO \
ACTIVEMQ_BROKER_URI=tcp://localhost:61616 \
FCREPO_ACTIVEMQ_CONFIGURATION=classpath:/config/activemq.xml \
FCREPO_SPRING_CONFIGURATION=classpath:/spring/master.xml \
FCREPO_MODESHAPE_CONFIGURATION=classpath:/pass-repository.json \
FCREPO_JMS_CONFIGURATION=classpath:/spring/jms.xml \
SLF4J_VERSION=1.7.25 \
DEBUG_PORT=5006 \
DEBUG_ARG="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5006" \
COMPACTION_URI=https://oa-pass.github.io/pass-data-model/src/main/resources/context-2.0.jsonld \
COMPACTION_PRELOAD_URI_PASS_STATIC=https://oa-pass.github.io/pass-data-model/src/main/resources/context-2.0.jsonld \
COMPACTION_PRELOAD_FILE_PASS_STATIC=/usr/local/tomcat/lib/context-2.0.jsonld \
JSONLD_STRICT=true \
JSONLD_CONTEXT_PERSIST=true \
JSONLD_CONTEXT_MINIMAL=true

EXPOSE ${DEBUG_PORT}
EXPOSE ${FCREPO_PORT}

COPY bin/* /bin/
COPY conf/* ${CATALINA_HOME}/conf/
COPY lib/* ${CATALINA_HOME}/lib/
COPY tomcat-bin/* ${CATALINA_HOME}/bin/

RUN apk update && \
    apk add --no-cache ca-certificates wget gettext curl && \
    export FCREPO_WAR=fcrepo-webapp-${FCREPO_VERSION}.war && \ 
    wget -O ${CATALINA_HOME}/webapps/fcrepo.war \
    http://central.maven.org/maven2/org/fcrepo/fcrepo-webapp-plus/${FCREPO_VERSION}/fcrepo-webapp-plus-${FCREPO_VERSION}.war && \
    #https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-${FCREPO_VERSION}/fcrepo-webapp-plus-webac-${FCREPO_VERSION}.war && \
    echo "95cd04e17eebfc9af5dd7a0968293f92bfd75bf0 *${CATALINA_HOME}/webapps/fcrepo.war" \
        | sha1sum -c -  && \
    echo "org.apache.catalina.webresources.Cache.level = SEVERE" \
      >> ${CATALINA_HOME}/conf/logging.properties && \
    wget -O ${CATALINA_HOME}/lib/jsonld-addon-filters-0.0.5-SNAPSHOT-shaded.jar \
        https://github.com/DataConservancy/fcrepo-jsonld/releases/download/0.0.5-SNAPSHOT/jsonld-addon-filters-0.0.5-SNAPSHOT-shaded.jar && \
    mkdir ${CATALINA_HOME}/webapps/fcrepo && \
    unzip ${CATALINA_HOME}/webapps/fcrepo.war -d ${CATALINA_HOME}/webapps/fcrepo  && \
    rm ${CATALINA_HOME}/webapps/fcrepo.war && \
    wget -O ${CATALINA_HOME}/webapps/fcrepo/WEB-INF/lib/jms-addon-0.0.1.jar \
            https://github.com/DataConservancy/fcrepo-jms/releases/download/jms-addon-0.0.1/jms-addon-0.0.1.jar && \
    chmod 700 /bin/entrypoint.sh && \
    chmod 700 /bin/setup_fedora.sh

 RUN export FCREPO_ACTIVEMQ_CONFIGURATION=classpath:/activemq-queue.xml && \
    export FCREPO_JMS_BASEURL=http://${FCREPO_HOST}:${FCREPO_PORT}/fcrepo/rest && \
    /bin/entrypoint.sh startup.sh && \
    /bin/setup_fedora.sh http://127.0.0.1:${FCREPO_PORT}/${FCREPO_CONTEXT_PATH}/rest && \
    ${CATALINA_HOME}/bin/shutdown.sh && \
    sed -i '/bootstrap/d' conf/tomcat-users.xml

RUN wget -O ${CATALINA_HOME}/lib/context-2.0.jsonld \
   ${COMPACTION_URI}

COPY WEB-INF/ ${CATALINA_HOME}/webapps/fcrepo/WEB-INF/

ENTRYPOINT [ "/bin/entrypoint.sh" ]
