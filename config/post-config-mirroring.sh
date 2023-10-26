#!/bin/bash

echo "#### Custom config start. ####"

cc=""

cc="      ${cc}<broker-connections>\n"
cc="      ${cc}  <amqp-connection uri=\"tcp://ex-aao-artemis-0-svc.pocamqbroker2.svc.cluster.local:61616\" name=\"DC1\">\n"
cc="      ${cc}    <mirror/>\n"
cc="      ${cc}  </amqp-connection>\n"
cc="      ${cc}</broker-connections>\n\n"

cc="       ${cc}<addresses>\n"
cc="       ${cc}   <address name=\"DLQ\">\n"
cc="       ${cc}      <anycast>\n"
cc="       ${cc}         <queue name=\"DLQ\" />\n"
cc="       ${cc}      </anycast>\n"
cc="       ${cc}   </address>\n"
cc="       ${cc}   <address name=\"ExpiryQueue\">\n"
cc="       ${cc}      <anycast>\n"
cc="       ${cc}         <queue name=\"ExpiryQueue\" />\n"
cc="       ${cc}      </anycast>\n"
cc="       ${cc}   </address>\n"

cc="       ${cc}   <address name=\"exampleTopic\">\n"
cc="       ${cc}      <multicast/>\n"
cc="       ${cc}   </address>\n"

cc="       ${cc}   <address name=\"exampleQueue\">\n"
cc="       ${cc}      <anycast>\n"
cc="       ${cc}         <queue name=\"exampleQueue\"/>\n"
cc="       ${cc}      </anycast>\n"
cc="       ${cc}   </address>\n"

cc="       ${cc}   <address name=\"test\">\n"
cc="       ${cc}      <multicast/>\n"
cc="       ${cc}   </address>\n"
cc="       ${cc}   <address name=\"/topic/test\">\n"
cc="       ${cc}      <multicast/>\n"
cc="       ${cc}   </address>\n"
cc="       ${cc}</addresses>\n\n"

cc="       ${cc}<security-enabled>false</security-enabled>\n\n"

sed -i '/<addresses>/,/<\/addresses>/d' ${CONFIG_INSTANCE_DIR}/etc/broker.xml

sed -i '/<cluster-connections>/,/<\/cluster-connections>/d' ${CONFIG_INSTANCE_DIR}/etc/broker.xml

sed -i "s|  </discovery-groups>| </discovery-groups> ${cc} |g" ${CONFIG_INSTANCE_DIR}/etc/broker.xml

echo "#### Custom config done. ####"
