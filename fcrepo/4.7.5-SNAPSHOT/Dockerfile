FROM tomcat:8.5.31-jre8-alpine@sha256:f9a53932a3cc61ea3a1c307e7bf60897bce356c60c61beb0a1d1cdc5c13c9b83

ENV FCREPO_VERSION=4.7.5 \
JSONLD_ADDON_VERSION=0.0.6-SNAPSHOT \
PASS_AUTHZ_VERSION=0.1.1-SNAPSHOT \
JMS_ADDON_VERSION=0.0.2 \
FCREPO_HOME=${CATALINA_HOME}/fcrepo4-data \
FCREPO_HOST=fcrepo \
FCREPO_PORT=8080 \
FCREPO_JMS_PORT=61616 \
FCREPO_STOMP_PORT=61613 \
FCREPO_CONTEXT_PATH=/fcrepo \
FCREPO_LOG_LEVEL=INFO \
SPRING_ACTIVEMQ_URL=tcp://localhost:61616 \
FCREPO_CONNECTIONFACTORY=org.apache.activemq.ActiveMQConnectionFactory \
FCREPO_JMS_PUBLISHER=org.fcrepo.jms.JMSTopicPublisher \
FCREPO_JMS_DESTINATION=fedora \
FCREPO_ACTIVEMQ_CONFIGURATION=classpath:/config/activemq.xml \
FCREPO_SPRING_CONFIGURATION=classpath:/spring/master.xml \
FCREPO_MODESHAPE_CONFIGURATION=classpath:/pass-repository.json \
FCREPO_JMS_CONFIGURATION=classpath:/pass-jms.xml \
FCREPO_LOGBACK_LOCATION=webapps/fcrepo/WEB-INF/classes/logback.xml \
FCREPO_PROPERTIES_MANAGEMENT=relaxed \
SLF4J_VERSION=1.7.25 \
DEBUG_ARG="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5006" \
COMPACTION_URI=https://oa-pass.github.io/pass-data-model/src/main/resources/context-2.3.jsonld \
COMPACTION_PRELOAD_URI_PASS_STATIC_2_0=https://oa-pass.github.io/pass-data-model/src/main/resources/context-2.0.jsonld \
COMPACTION_PRELOAD_FILE_PASS_STATIC_2_0=/usr/local/tomcat/lib/context-2.0.jsonld \
COMPACTION_PRELOAD_URI_PASS_STATIC_2_1=https://oa-pass.github.io/pass-data-model/src/main/resources/context-2.1.jsonld \
COMPACTION_PRELOAD_FILE_PASS_STATIC_2_1=/usr/local/tomcat/lib/context-2.1.jsonld \
COMPACTION_PRELOAD_URI_PASS_STATIC_2_2=https://oa-pass.github.io/pass-data-model/src/main/resources/context-2.2.jsonld \
COMPACTION_PRELOAD_FILE_PASS_STATIC_2_2=/usr/local/tomcat/lib/context-2.2.jsonld \
COMPACTION_PRELOAD_URI_PASS_STATIC_2_3=https://oa-pass.github.io/pass-data-model/src/main/resources/context-2.3.jsonld \
COMPACTION_PRELOAD_FILE_PASS_STATIC_2_3=/usr/local/tomcat/lib/context-2.3.jsonld \
JSONLD_STRICT=true \
JSONLD_CONTEXT_PERSIST=true \
JSONLD_CONTEXT_MINIMAL=true \
AUTHZ_USE_SHIB_HEADERS=true

EXPOSE ${FCREPO_PORT}

VOLUME /data

COPY bin/* /bin/
COPY conf/* ${CATALINA_HOME}/conf/
COPY lib/* ${CATALINA_HOME}/lib/
COPY tomcat-bin/* ${CATALINA_HOME}/bin/

RUN apk update && \
    apk add --no-cache ca-certificates wget gettext curl python py-pip && \
    pip install awscli && \
    export FCREPO_WAR=fcrepo-webapp-${FCREPO_VERSION}.war && \
    wget -O ${CATALINA_HOME}/webapps/fcrepo.war \
    http://central.maven.org/maven2/org/fcrepo/fcrepo-webapp-plus/${FCREPO_VERSION}/fcrepo-webapp-plus-${FCREPO_VERSION}.war && \
    #https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-${FCREPO_VERSION}/fcrepo-webapp-plus-webac-${FCREPO_VERSION}.war && \
    echo "95cd04e17eebfc9af5dd7a0968293f92bfd75bf0 *${CATALINA_HOME}/webapps/fcrepo.war" \
        | sha1sum -c -  && \
    echo "org.apache.catalina.webresources.Cache.level = SEVERE" \
      >> ${CATALINA_HOME}/conf/logging.properties && \
    wget -O ${CATALINA_HOME}/lib/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar \
        https://github.com/DataConservancy/fcrepo-jsonld/releases/download/${JSONLD_ADDON_VERSION}/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar && \
    echo "fa95adf77b0933f163e213f8133e8d78df7a9141 *${CATALINA_HOME}/lib/jsonld-addon-filters-${JSONLD_ADDON_VERSION}-shaded.jar" \
        | sha1sum -c -  && \
    wget -O ${CATALINA_HOME}/lib/pass-authz-filters-shaded.jar \
        https://github.com/OA-PASS/pass-authz/releases/download/${PASS_AUTHZ_VERSION}/pass-authz-filters-${PASS_AUTHZ_VERSION}-shaded.jar && \
    echo "2e1e0d4b39b32304a66bccc1a0821d58674a0234 *${CATALINA_HOME}/lib/pass-authz-filters-shaded.jar" \
        | sha1sum -c -  && \
    wget -O ${CATALINA_HOME}/webapps/pass-user-service.war \
        https://github.com/OA-PASS/pass-authz/releases/download/${PASS_AUTHZ_VERSION}/pass-user-service-${PASS_AUTHZ_VERSION}.war && \
    echo "502bcbff78497f00a93038f3e3596dcf7dd3c010 *${CATALINA_HOME}/webapps/pass-user-service.war" \
        | sha1sum -c -  && \
    mkdir ${CATALINA_HOME}/webapps/pass-user-service && \
    unzip ${CATALINA_HOME}/webapps/pass-user-service.war -d ${CATALINA_HOME}/webapps/pass-user-service  && \
    rm ${CATALINA_HOME}/webapps/pass-user-service.war && \
    mkdir ${CATALINA_HOME}/webapps/fcrepo && \
    unzip ${CATALINA_HOME}/webapps/fcrepo.war -d ${CATALINA_HOME}/webapps/fcrepo  && \
    rm ${CATALINA_HOME}/webapps/fcrepo.war && \
    wget -O ${CATALINA_HOME}/webapps/fcrepo/WEB-INF/lib/jms-addon-${JMS_ADDON_VERSION}.jar \
            https://github.com/DataConservancy/fcrepo-jms/releases/download/jms-addon-${JMS_ADDON_VERSION}/jms-addon-${JMS_ADDON_VERSION}.jar && \
    echo "5f3cbb87fc9117b5761efa38c0a085b017166729 *${CATALINA_HOME}/webapps/fcrepo/WEB-INF/lib/jms-addon-${JMS_ADDON_VERSION}.jar" \
        | sha1sum -c -  && \
    chmod 700 /bin/entrypoint.sh && \
    chmod 700 /bin/setup_fedora.sh && \
    chmod 700 /bin/awsentrypoint.sh

RUN export FCREPO_ACTIVEMQ_CONFIGURATION=classpath:/activemq-queue.xml && \
    export FCREPO_JMS_BASEURL=http://${FCREPO_HOST}:${FCREPO_PORT}/fcrepo/rest && \
    /bin/entrypoint.sh startup.sh && \
    /bin/setup_fedora.sh http://127.0.0.1:${FCREPO_PORT}/${FCREPO_CONTEXT_PATH}/rest && \
    ${CATALINA_HOME}/bin/shutdown.sh && \
    sed -i '/bootstrap/d' conf/tomcat-users.xml

RUN wget -O ${COMPACTION_PRELOAD_FILE_PASS_STATIC_2_0} \
        ${COMPACTION_PRELOAD_URI_PASS_STATIC_2_0} && \
    wget -O ${COMPACTION_PRELOAD_FILE_PASS_STATIC_2_1} \
        ${COMPACTION_PRELOAD_URI_PASS_STATIC_2_1} && \
    wget -O ${COMPACTION_PRELOAD_FILE_PASS_STATIC_2_2} \
        ${COMPACTION_PRELOAD_URI_PASS_STATIC_2_2} && \
    wget -O ${COMPACTION_PRELOAD_FILE_PASS_STATIC_2_3} \
                ${COMPACTION_PRELOAD_URI_PASS_STATIC_2_3} && \
    rm ${CATALINA_HOME}/webapps/fcrepo/WEB-INF/lib/modeshape-jcr-5.4.0.Final.jar && \
    wget -O ${CATALINA_HOME}/webapps/fcrepo/WEB-INF/lib/modeshape-jcr-5.4.0-maint-01.jar \
        https://github.com/OA-PASS/modeshape/releases/download/modeshape-5.4.0-maint-01/modeshape-jcr-5.4.0.Final.jar && \
    echo "159697fd2c15db3c9caf47f52f64c453e1ed67a2 *${CATALINA_HOME}/webapps/fcrepo/WEB-INF/lib/modeshape-jcr-5.4.0-maint-01.jar" \
        | sha1sum -c -

COPY WEB-INF/ ${CATALINA_HOME}/webapps/fcrepo/WEB-INF/

ENTRYPOINT [ "/bin/entrypoint.sh" ]
