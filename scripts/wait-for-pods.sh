#!/usr/bin/env bash

TIMEOUT_SECS=15
SLEEP_TIME_SECS=5
WAITED_SECS=0

#How many pods 
pods_count=`kubectl get pods | grep -v "^NAME" | wc -l`
running_count=

# wait for pods all to get to Running state
while [  `kubectl get pods | awk '{ print $3 }' | grep Running | wc -l` lt $pods_count  ] ; do
    echo -n "Waiting for all pods to be in Running state"
    if [ $WAITED_SECS -le $TIMEOUT_SECS ] ; then
        echo "waiting for $SLEEP_TIME_SECS secs ; total time waited : $WAITED_SECS secs "
        ((WAITED_SECS+=$SLEEP_TIME_SECS))
        sleep $SLEEP_TIME_SECS
    else
        echo "timeout waiting for tiller to become ready"
        break
    fi
done
if [ $WAITED_SECS -le $TIMEOUT_SECS ] ; then 
    echo "All pods in Running state"
else
    echo "Some pods failed to reach Running state in $TIMEOUT_SECS secs "
fi


