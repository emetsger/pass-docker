#!/bin/sh
CMD="java -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap ${NOTIFICATION_OPTS} -jar notification-services.jar"

echo "Running ${CMD}"

exec $CMD