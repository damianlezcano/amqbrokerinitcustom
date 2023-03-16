FROM quay.io/artemiscloud/activemq-artemis-broker-init:0.2.4

ADD config /amq/scripts 

USER root
RUN chmod -R 774 /amq/scripts 
USER jboss