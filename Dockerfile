FROM registry.redhat.io/amq7/amq-broker-init-rhel8:7.10-38.1675807822

# opciones: clustering y mirroring
ARG PROFILE=clustering

ADD config/post-config-${PROFILE}.sh /amq/scripts/post-config.sh

USER root
RUN chmod -R 774 /amq/scripts 
USER jboss