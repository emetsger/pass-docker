#!/bin/sh

CMD="catalina.sh run"

if [ $# -eq 1 ]; then
    CMD=${1}
fi

# handle port
sed -ie "s:<Connector port=\"8080\":<Connector port=\"${FCREPO_PORT}\":" conf/server.xml

# Prefer the API-X base uri as the JMS base url
if [ -n "${FCREPO_JMS_BASEURL}" ] ;
then 
  _JMS_BASEURL=${FCREPO_JMS_BASEURL}
elif [ -n "${PUBLIC_REPOSITORY_BASEURI}" ] ;
then
  _JMS_BASEURL=${PUBLIC_REPOSITORY_BASEURI}
else
  # if the public repository base uri is not set, and Fedora is running on port 80, omit
  # the port number from the JMS base url
  if [ -z "${FCREPO_PORT}" -o "${FCREPO_PORT}" == "8080" ] ;
  then
    _JMS_BASEURL="http://${FCREPO_HOST}${FCREPO_CONTEXT_PATH}/rest"
  else
    _JMS_BASEURL="http://${FCREPO_HOST}:${FCREPO_PORT}${FCREPO_CONTEXT_PATH}/rest"
  fi
fi

OPTS="-Dfcrepo.log=${FCREPO_LOG_LEVEL}
      -Dfcrepo.log.auth=${FCREPO_AUTH_LOG_LEVEL}                             \
      -Dfcrepo.log.jms=${FCREPO_LOG_JMS}                                     \
      -Dfcrepo.jms.baseUrl=${_JMS_BASEURL}                                   \
      -Dfcrepo.spring.jms.configuration=${FCREPO_JMS_CONFIGURATION}          \
      -Dfcrepo.modeshape.configuration=${FCREPO_MODESHAPE_CONFIGURATION}     \
      -Dfcrepo.spring.configuration=${FCREPO_SPRING_CONFIGURATION}           \
      -Dfcrepo.postgresql.host=${FCREPO_POSTGRESQL_HOST}                     \
      -Dfcrepo.postgresql.port=${FCREPO_POSTGRESQL_PORT}                     \
      -Dfcrepo.postgresql.username=${FCREPO_POSTGRESQL_USERNAME}             \
      -Dfcrepo.postgresql.password=${FCREPO_POSTGRESQL_PASSWORD}             \
      -Dfcrepo.binary.directory=${FCREPO_BINARY_DIRECTORY}                   \
      -Dfcrepo.activemq.directory=${FCREPO_ACTIVEMQ_DIRECTORY}               \
      -Dfcrepo.modeshape.index.directory=${FCREPO_MODESHAPE_INDEX_DIRECTORY} \
      -Dfcrepo.object.directory=${FCREPO_OBJECT_DIRECTORY}                   \
      -Dfcrepo.activemq.configuration=${FCREPO_ACTIVEMQ_CONFIGURATION}       \
      -Dactivemq.broker.uri=${ACTIVEMQ_BROKER_URI}                           \
      -Dfcrepo.dynamic.jms.port=${FCREPO_JMS_PORT}                           \
      -Dfcrepo.dynamic.stomp.port=${FCREPO_STOMP_PORT}                       \
      -Dcom.arjuna.ats.arjuna.objectstore.objectStoreDir=${ARJUNA_OBJECTSTORE_DIRECTORY}"

if [ -n "${FCREPO_JMX_PORT}" ]
then
  OPTS="${OPTS}                                                              \
  -Dcom.sun.management.jmxremote                                             \
  -Djava.rmi.server.hostname=$(hostname -i)                                  \
  -Dcom.sun.management.jmxremote.local.only=false                            \
  -Dcom.sun.management.jmxremote.authenticate=false                          \
  -Dcom.sun.management.jmxremote.port=${FCREPO_JMX_PORT}                     \
  -Dcom.sun.management.jmxremote.rmi.port=${FCREPO_JMX_PORT}
  -Dcom.sun.management.jmxremote.ssl=false                                   "
fi

# handle debugging

if [ -n "${DEBUG_PORT}" ] ;
then
  OPTS="${OPTS} `echo ${DEBUG_ARG} | envsubst`"
fi

CATALINA_OPTS="${OPTS}" ${CMD}
