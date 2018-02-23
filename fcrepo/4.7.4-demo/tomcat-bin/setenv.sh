#!/bin/bash

if [ "${FCREPO_TOMCAT_REQUEST_DUMPER_ENABLED:=false}" != "false" ] ;
then
  export CATALINA_OPTS="${CATALINA_OPTS} -Drequestdumper.log.level=INFO"
else
  export CATALINA_OPTS="${CATALINA_OPTS} -Drequestdumper.log.level=WARNING"
fi