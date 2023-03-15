#!/bin/bash

echo "#### Custom config start. ####"

#diverts=""
#diverts="      ${diverts}<diverts>\n"
#diverts="      ${diverts} <divert name=\"prices-divert\">\n"
#diverts="      ${diverts}  <address>priceUpdates</address>\n"
#diverts="      ${diverts}  <forwarding-address>priceForwarding</forwarding-address>\n"
#diverts="      ${diverts}  <exclusive>false</exclusive>\n"
#diverts="      ${diverts} </divert>\n"
#diverts="      ${diverts}</diverts>\n\n"
#address=""
#address="      ${address}<address name=\"priceForwarding\">\n"
#address="      ${address} <anycast>\n"
#address="      ${address}  <queue name=\"priceForwarding\" />\n"
#address="      ${address} </anycast>\n"
#address="      ${address}</address>\n\n"
#address="      ${address}<address name=\"priceUpdates\">\n"
#address="      ${address} <anycast>\n"
#address="      ${address}  <queue name=\"priceUpdates\" />\n"
#address="      ${address} </anycast>\n"
#address="      ${address}</address>\n\n"

#sed -i "s|  <addresses>|${diverts}  <addresses> ${address}|g" ${CONFIG_INSTANCE_DIR}/etc/broker.xml

echo "#### Custom config done. ####"