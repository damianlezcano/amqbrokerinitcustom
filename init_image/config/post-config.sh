#!/bin/bash

echo "#### Custom config start. #### v2"


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

# removemos el tag
sed -i '/<cluster-connections>/,/<\/cluster-connections>/d' ${CONFIG_INSTANCE_DIR}/etc/broker.xml

# generamos el tag justo arriba de security-settings
sed -i "s|  <security-settings>|${diverts}  <security-settings> ${address}|g" ${CONFIG_INSTANCE_DIR}/etc/broker.xml

echo "#### Custom config done. ####"