FROM quay.io/artemiscloud/activemq-artemis-broker-init:0.2.4

ADD config /amq/scripts 

# para pruebas: borrar
# ADD broker.xml /broker/etc/broker.xml
# para pruebas: borrar

USER root
RUN chmod -R 774 /amq/scripts 
USER jboss