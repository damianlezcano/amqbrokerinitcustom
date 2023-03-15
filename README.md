
oc login --token=sha256~CRIEnAC-EwbFNp_a5T_Zii5Xjm_FlPkFG8rvvuceFvc --server=https://api.cluster-mksbk.mksbk.sandbox1571.opentlc.com:6443

----------------------------

oc new-project pocamqbroker1

Instalamos operador 

Red Hat Integration - AMQ Broker for RHEL 8 (Multiarch) 7.10.2-opr-2+0.1676475747.p provided by Red Hat

oc create -f <(echo '
apiVersion: broker.amq.io/v1beta1
kind: ActiveMQArtemis
metadata:
  name: ex-aao
  namespace: pocamqbroker1
spec:
  adminPassword: redaht01
  adminUser: admin
  console:
    expose: true
  deploymentPlan:
    image: placeholder
    jolokiaAgentEnabled: false
    journalType: nio
    managementRBACEnabled: true
    messageMigration: false
    persistenceEnabled: false
    requireLogin: false
    size: 1
    extraMounts:
        configMaps:
          - amq-broker
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values:
                    - ip-10-0-145-80
')

oc create configmap amq-broker --from-file=broker.xml=broker.xml -n pocamqbroker1

------------------------------

oc new-project pocamqbroker2

Instalamos operador 

Red Hat Integration - AMQ Broker for RHEL 8 (Multiarch) 7.10.2-opr-2+0.1676475747.p provided by Red Hat

oc create -f <(echo '
apiVersion: broker.amq.io/v1beta1
kind: ActiveMQArtemis
metadata:
  name: ex-aao
  namespace: pocamqbroker1
spec:
  adminPassword: redaht01
  adminUser: admin
  console:
    expose: true
  deploymentPlan:
    image: placeholder
    jolokiaAgentEnabled: false
    journalType: nio
    managementRBACEnabled: true
    messageMigration: false
    persistenceEnabled: false
    requireLogin: false
    size: 1
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/hostname
                  operator: In
                  values:
                    - ip-10-0-241-28
')


oc create configmap configmap-amq-broker --from-file=broker.xml=broker.xml -n pocamqbroker2

------------------

docker build -t init-custom:v1 .

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

