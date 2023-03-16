FROM registry.redhat.io/amq7/amq-broker-init-rhel8:7.10-38.1675807822

ADD config /amq/scripts 

# para pruebas: borrar
#ADD broker.xml /broker/etc/broker.xml
# para pruebas: borrar

USER root
RUN chmod -R 774 /amq/scripts 
USER jboss