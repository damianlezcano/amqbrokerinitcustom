#!/bin/bash

echo "#### Custom config start. ####"


diverts=""
diverts="      ${diverts}<cluster-connections>\n"
diverts="      ${diverts}   <cluster-connection name=\"my-cluster\">\n"
diverts="      ${diverts}      <connector-ref>artemis</connector-ref>\n"
diverts="      ${diverts}      <static-connectors>\n"
diverts="      ${diverts}         <connector-ref>broker1-connector</connector-ref>\n"
diverts="      ${diverts}         <connector-ref>broker2-connector</connector-ref>\n"
diverts="      ${diverts}      </static-connectors>\n"
diverts="      ${diverts}   </cluster-connection>\n"
diverts="      ${diverts}</cluster-connections>\n\n"


sed -i "s|  <addresses>|${diverts}  <addresses> ${address}|g" ${CONFIG_INSTANCE_DIR}/etc/broker.xml

echo "#### Custom config done. ####"