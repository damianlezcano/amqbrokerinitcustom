#!/bin/bash

echo "#### Custom config start. #### v4"

cc=""
cc="      ${cc}\n\n<cluster-connections>\n"
cc="      ${cc}   <cluster-connection name=\"my-cluster\">\n"
cc="      ${cc}      <connector-ref>artemis</connector-ref>\n"
cc="      ${cc}      <retry-interval>500</retry-interval>\n"
cc="      ${cc}      <use-duplicate-detection>true</use-duplicate-detection>\n"
cc="      ${cc}      <message-load-balancing>STRICT</message-load-balancing>\n"
cc="      ${cc}      <max-hops>1</max-hops>\n"
cc="      ${cc}      <static-connectors>\n"
cc="      ${cc}         <connector-ref>broker1-connector</connector-ref>\n"
cc="      ${cc}         <connector-ref>broker2-connector</connector-ref>\n"
cc="      ${cc}      </static-connectors>\n"
cc="      ${cc}   </cluster-connection>\n"
cc="      ${cc}</cluster-connections>\n\n"


# removemos el tag
sed -i '/<cluster-connections>/,/<\/cluster-connections>/d' ${CONFIG_INSTANCE_DIR}/etc/broker.xml

# generamos el tag justo arriba de discovery-groups
sed -i "s|  </discovery-groups>| </discovery-groups> ${cc} |g" ${CONFIG_INSTANCE_DIR}/etc/broker.xml


echo "#### Custom config done. ####"