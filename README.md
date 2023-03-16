https://access.redhat.com/documentation/en-us/red_hat_amq_broker/7.10/html-single/configuring_amq_broker/index#configuring-fault-tolerant-system-broker-connections-configuring

https://activemq.apache.org/components/artemis/documentation/latest/amqp-broker-connections.html

oc login --token=sha256~CRIEnAC-EwbFNp_a5T_Zii5Xjm_FlPkFG8rvvuceFvc --server=https://api.cluster-mksbk.mksbk.sandbox1571.opentlc.com:6443

----------------------------

oc new-project pocamqbroker1

Instalamos operador 

Red Hat Integration - AMQ Broker for RHEL 8 (Multiarch) 7.10.2-opr-2+0.1676475747.p provided by Red Hat

```bash
oc create -f <(echo '
apiVersion: broker.amq.io/v1beta1
kind: ActiveMQArtemis
metadata:
  name: ex-aao
  namespace: pocamqbroker1

spec:
  acceptors:
    - port: 61616
      verifyHost: false
      wantClientAuth: false
      expose: true
      needClientAuth: false
      multicastPrefix: /topic/
      name: stomp
      sslEnabled: false
      sniHost: localhost
      protocols: 'CORE,AMQP,STOMP,HORNETQ,MQTT,OPENWIRE'
      sslProvider: JDK
      anycastPrefix: jms.topic.
  adminPassword: redaht01
  adminUser: admin
  connectors:
    - host: ex-aao-stomp-0-svc.pocamqbroker1.svc.cluster.local
      name: broker1-connector
      port: 61616
      sslEnabled: false
    - host: ex-aao-stomp-0-svc.pocamqbroker2.svc.cluster.local
      name: broker2-connector
      port: 61616
      sslEnabled: false
  console:
    expose: true
  deploymentPlan:
    size: 1
    initImage: image-registry.openshift-image-registry.svc:5000/openshift/amqbrokerinitcustom:v1
    persistenceEnabled: true
    messageMigration: true
    requireLogin: false
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values:
                    - ip-10-0-145-80
    managementRBACEnabled: true
    journalType: nio
    jolokiaAgentEnabled: false
    image: placeholder
')
```

oc create configmap amq-broker --from-file=broker.xml=broker.xml -n pocamqbroker1

------------------------------

oc new-project pocamqbroker2

Instalamos operador 

Red Hat Integration - AMQ Broker for RHEL 8 (Multiarch) 7.10.2-opr-2+0.1676475747.p provided by Red Hat

```bash
oc create -f <(echo '
apiVersion: broker.amq.io/v1beta1
kind: ActiveMQArtemis
metadata:
  name: ex-aao
  namespace: pocamqbroker2
spec:
  acceptors:
    - port: 61616
      verifyHost: false
      wantClientAuth: false
      expose: true
      needClientAuth: false
      multicastPrefix: /topic/
      name: stomp
      sslEnabled: false
      sniHost: localhost
      protocols: 'CORE,AMQP,STOMP,HORNETQ,MQTT,OPENWIRE'
      sslProvider: JDK
      anycastPrefix: jms.topic.
  adminPassword: redaht01
  adminUser: admin
  connectors:
    - host: ex-aao-stomp-0-svc.pocamqbroker1.svc.cluster.local
      name: broker1-connector
      port: 61616
      sslEnabled: false
    - host: ex-aao-stomp-0-svc.pocamqbroker2.svc.cluster.local
      name: broker2-connector
      port: 61616
      sslEnabled: false
  console:
    expose: true
  deploymentPlan:
    size: 1
    persistenceEnabled: false
    requireLogin: false
    messageMigration: false
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values:
                    - ip-10-0-154-38
    initImage: >-
      image-registry.openshift-image-registry.svc:5000/openshift/amqbrokerinitcustom:v6
    managementRBACEnabled: true
    journalType: nio
    jolokiaAgentEnabled: false
    image: placeholder
')
```

oc create configmap configmap-amq-broker --from-file=broker.xml=broker.xml -n pocamqbroker2

------------------

docker build -t init-custom:v2 .

docker run --rm -t -i --name init-custom -v $PWD/config/post-config.sh:/amq/scripts/post-config.sh: init-custom:v2 /bin/bash

chmod -R 774 /amq/scripts;sh /opt/amq-broker/script/default.sh
---

# Publico la ruta de la registry
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge

# Obtenemos la Ruta
HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')

# Nos autenticamos a la registry
docker login -u opentlc-mgr -p $(oc whoami -t) $HOST

# Disponibilizamos la imagen en el cluster de ocp
docker tag init-custom:v1 $HOST/openshift/init-custom:v1
docker push $HOST/openshift/init-custom:v1

------------------

oc scale deployment/amq-broker-operator --replicas=0 -n openshift-operators
oc set env statefulset/ex-aao-ss BROKER_XML="$(xmllint --noblanks ./broker.xml | tr '\n' ' ')" -n pocamqbroker1
oc set env statefulset/ex-aao-ss BROKER_XML="$(xmllint --noblanks ./broker.xml | tr '\n' ' ')" -n pocamqbroker2

------------------

```yaml
kind: ImageStream
apiVersion: image.openshift.io/v1
metadata:
  name: amqbrokerinitcustom
  namespace: openshift
spec:
  lookupPolicy:
    local: false
```

```yaml
kind: BuildConfig
apiVersion: build.openshift.io/v1
metadata:
  name: amqbrokerinitcustom
  namespace: openshift
spec:
  nodeSelector: null
  output:
    to:
      kind: ImageStreamTag
      name: 'amqbrokerinitcustom:latest'
  resources: {}
  successfulBuildsHistoryLimit: 5
  failedBuildsHistoryLimit: 5
  strategy:
    type: Docker
    dockerStrategy:
      dockerfilePath: Dockerfile
  postCommit: {}
  source:
    type: Git
    git:
      uri: 'https://github.com/damianlezcano/amqbrokerinitcustom.git'
    contextDir: /init_image
  runPolicy: Serial

```


oc exec --stdin --tty ex-aao-ss-0 -- /bin/bash

oc debug statefulsets/ex-aao-ss
cd /opt/amq/bin/;./launch.sh;cd /home/jboss/amq-broker/etc



oc exec ex-aao-ss-0 -n pocamqbroker1 -- /bin/bash /home/jboss/amq-broker/bin/artemis producer --user admin --password redhat01 --url tcp://ex-aao-ss-0:61616 --destination example --message-count 1

oc exec ex-aao-ss-0 -n pocamqbroker1 -- /bin/bash /home/jboss/amq-broker/bin/artemis queue stat --user admin --password admin --url tcp://ex-aao-ss-0:61616

oc exec ex-aao-ss-0 -n pocamqbroker2 -- /bin/bash /home/jboss/amq-broker/bin/artemis queue stat --user admin --password admin --url tcp://ex-aao-ss-0:61616


oc exec ex-aao-ss-0 -n pocamqbroker1 -- /bin/bash /home/jboss/amq-broker/bin/artemis consumer --destination example  --message-count=1 --url tcp://ex-aao-ss-0:61616

oc exec ex-aao-ss-0 -n pocamqbroker2 -- /bin/bash /home/jboss/amq-broker/bin/artemis consumer --destination example  --message-count=1 --url tcp://ex-aao-ss-0:61616