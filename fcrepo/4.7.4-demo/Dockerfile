FROM tomcat:8.5.24-jre8-alpine

ENV FCREPO_VERSION=4.7.4 \
FCREPO_HOST=localhost \
FCREPO_PORT=8080 \
FCREPO_JMS_PORT=61616 \
FCREPO_STOMP_PORT=61613 \
FCREPO_CONTEXT_PATH=/fcrepo \
FCREPO_LOG_LEVEL=INFO \
FCREPO_MODESHAPE_CONFIGURATION=classpath:/config/file-simple/repository.json \
ACTIVEMQ_BROKER_URI=tcp://localhost:61616 \
FCREPO_ACTIVEMQ_CONFIGURATION=classpath:/config/activemq.xml \
FCREPO_SPRING_CONFIGURATION=classpath:/spring/master.xml \
DEBUG_PORT=5006 \
DEBUG_ARG="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5006"

EXPOSE ${DEBUG_PORT}
EXPOSE ${FCREPO_PORT}

COPY bin/* /bin/
COPY conf/* ${CATALINA_HOME}/conf/

RUN apk update && \
    apk add --no-cache ca-certificates wget gettext curl && \
    export FCREPO_WAR=fcrepo-webapp-${FCREPO_VERSION}.war && \ 
    wget -O ${CATALINA_HOME}/webapps/fcrepo.war \
    http://central.maven.org/maven2/org/fcrepo/fcrepo-webapp/4.7.4/fcrepo-webapp-4.7.4.war && \
    #https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-${FCREPO_VERSION}/fcrepo-webapp-plus-webac-${FCREPO_VERSION}.war && \
    #echo "6c66d18aa2f3813bae69d2dc16a00fbebf9366d3 *${CATALINA_HOME}/webapps/fcrepo.war" \
    #    | sha1sum -c -  && \
    echo "org.apache.catalina.webresources.Cache.level = SEVERE" \
      >> ${CATALINA_HOME}/conf/logging.properties && \
    mkdir ${CATALINA_HOME}/webapps/fcrepo && \
    unzip ${CATALINA_HOME}/webapps/fcrepo.war -d ${CATALINA_HOME}/webapps/fcrepo  && \
    rm ${CATALINA_HOME}/webapps/fcrepo.war && \
    chmod 700 /bin/entrypoint.sh && \
    chmod 700 /bin/setup_fedora.sh && \
    /bin/entrypoint.sh startup.sh && \
    /bin/setup_fedora.sh http://localhost:${FCREPO_PORT}/${FCREPO_CONTEXT_PATH}/rest && \
    ${CATALINA_HOME}/bin/shutdown.sh


COPY WEB-INF/* ${CATALINA_HOME}/webapps/fcrepo/WEB-INF/

ENTRYPOINT [ "/bin/entrypoint.sh" ]
