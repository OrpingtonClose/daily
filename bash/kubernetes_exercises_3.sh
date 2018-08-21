gcloud auth login
gcloud config set project $(gcloud projects list | awk '/avid/ {print $1}')
gcloud config set compute/zone europe-west1
gcloud container clusters create kubia --num-nodes 5 --machine-type f1-micro

#possible probes:
#tcp
#http
#exec - don't use with Java

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: kubia-liveliness
spec:
  containers:
  - image: luksa/kubia-unhealthy
    name: kubia
    livenessProbe:
      httpGet:
        path: /
	port: 8080
      initialDelaySeconds: 15
EOF

kubectl logs kubia-liveliness --previous
kubectl describe po kubia-liveliness
#Normal   Killing                6s (x2 over 1m)   kubelet, gke-kubia-default-pool-0f9e039a-jmw5  Killing container with id docker://kubia:Container failed liveness probe.. Container will be killed and recreated.
 
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: kubia-liveness-2
spec:
  containers:
  - image: luksa/kubia-unhealthy
    name: kubia
    livenessProbe:
      httpGet:
        path: /
        port: 8080
      initialDelaySeconds: 15
EOF

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ReplicationController
metadata:
  name: kubia
spec:
  replicas: 3
  selector:
    app: kubia
  template:
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - name: kubia
        image: luksa/kubia
	ports:
	- containerPort: 8080
EOF

kubectl get po | awk '{print $1}' | head -4  | tail -2 | xargs -n 1 kubectl delete po 
gcloud compute ssh gke-kubia-default-pool-a94d1538-q6z5 --zone europe-west1-c
sudo ifconfig eth0 down
#NotReady --> Unknown
gcloud compute instances reset gke-kubia-default-pool-a94d1538-q6z5 --zone europe-west1-c
#ready again

#Controlled By:  ReplicationController/kubia
kubectl label pod $(kubectl get po | tail -1 | awk '{print $1}') type=special

kubectl label pod $(kubectl get po | tail -1 | awk '{print $1}') app=foo --overwrite
# a new container is created by the replication controller

kubectl edit rc kubia
#export KUBE_EDITOR="/usr/bin/nano"

kubectl scale rc kubia --replicas 10
#leave pods alone
kubectl delete rc kubia --cascade false
kubectl delete po -l app=kubia

#replicasets add matchLabels
cat <<EOF | kubectl create -f -
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: kubia
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kubia
  template:
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - image: luksa/kubia
        name: kubia
EOF


cat <<EOF | kubectl create -f -
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: kubia
spec:
  replicas: 3
  selector:
    matchExpressions:
    - key: app
      operator: In
      values:
      - kubia
  template:
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - image: luksa/kubia
        name: kubia
EOF
#In
#NotIn
#Exists
#DoesNotExist

# not tried not tried not tried not tried
# not tried not tried not tried not tried
# not tried not tried not tried not tried
# not tried not tried not tried not tried
cat <<EOF | kubectl create -f -
apiVersion: apps/v1beta2
kind: DaemonSet
metadata:
  name: ssd-monitor
spec:
  selector:
    matchLabels:
      app: kubia-ssd
  template:
    metadata:
      labels:
        app: kubia-ssd
    spec:
      nodeSelectors:
        disk: ssd
      containers: 
      - image: luksa/ssd-monitor
        name: main
EOF

kubectl get ds
kubectl label node $(kubectl get node | tail -1 | awk '{print $1}') disk=ssd

cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 5
  parallelism: 2
  template:
    metadata:
      labels:
        app: batch-job
    spec:
      restartPolicy: OnFailure
      containers:
      - image: luksa/batch-job
        name: main
EOF
kubectl get jobs

kubectl get po -a # --show-all
kubectl scale job batch-job --replicas 3 #increases parallelism
#activateDadlineSeconds
#spec.backOffLimit

cat <<EOF | kubectl create -f -
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: batchjob-fifteen-minutes
spec:
  schedule: "0,15,30,45 * * * *"
  startingDeadlineSeconds: 15
  jobTemplate:
    spec:
      template:
        metadata:
	  labels:
	    app: periodic-job
	spec:
	  restartPolicy: OnFailure
	  containers:
	  - image: luksa/batch-job
	    name: main
EOF


