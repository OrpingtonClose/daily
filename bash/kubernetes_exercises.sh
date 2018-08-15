gcloud auth login
PROJECT=$(gcloud projects list | awk 'FNR==2 {print $1}')
gcloud config set project $PROJECT
gcloud config set compute/zone europe-west1
gcloud container clusters create kubia --num-nodes 2 --machine-type
gcloud container clusters get-credentials kubia

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: kubia-manual
spec:
  containers:
  - image: luksa/kubia
    name: kubia
    ports:
    - containerPort: 8080
      protocol: TCP
EOF

kubectl get po kubia-manual -o yaml
kubectl get po kubia-manual -o 

#port-forwarding
LOCAL_PORT=8888
CONTAINER_PORT=8080
kubectl port-forward kubia-manual $LOCAL_PORT:$CONTAINER_PORT &
curl localhost:$LOCAL_PORT

#logs from containers, which are collected from stdout and stderr
#logs rotate 10 mb limit
kubectl logs kubia-manual 
kubectl logs kubia-manual -c kubia

#labels
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: kubia-label
  labels:
    environment: prod
    something: not-bad
spec:
  containers:
  - image: luksa/kubia
    name: kubia
    ports:
    - containerPort: 8080
      protocol: TCP
EOF

#set pod with label. value is empty for the pod, so this will work
kubectl label pods kubia-manual environment=dev

#when overwriting value, put add a flag
kubectl label pods kubia-manual environment=devel --overwrite

#show pod info with labels
kubectl get po -L environment,something

#show pods with labels 
kubectl get po -l environment=prod
#NAME          READY     STATUS    RESTARTS   AGE       ENVIRONMENT   SOMETHING
#kubia-label   1/1       Running   0          11m       prod          not-bad

kubectl get pods -l something
#NAME          READY     STATUS    RESTARTS   AGE       ENVIRONMENT   SOMETHING
#kubia-label   1/1       Running   0          11m       prod          not-bad

kubectl get pods -l '!something'
#NAME           READY     STATUS    RESTARTS   AGE       SOMETHING   ENVIRONMENT
#kubia-manual   1/1       Running   0          44m                   devel

kubectl get pods -l 'environment in (not,devel)'
#NAME           READY     STATUS    RESTARTS   AGE       ENVIRONMENT   SOMETHING
#kubia-manual   1/1       Running   0          41m       devel         

kubectl get pods -l 'environment notin (not,devel)'
#NAME          READY     STATUS    RESTARTS   AGE       ENVIRONMENT   SOMETHING
#kubia-label   1/1       Running   0          17m       prod          not-bad

kubectl get po -l something=not-bad,environment=prod
#NAME          READY     STATUS    RESTARTS   AGE       ENVIRONMENT   SOMETHING
#kubia-label   1/1       Running   0          17m       prod          not-bad

kubectl get po -l 'environment!=prod'
#NAME           READY     STATUS    RESTARTS   AGE       ENVIRONMENT
#kubia-manual   1/1       Running   0          30m       devel

NODE=$(kubectl get node | awk 'FNR==2 {print $1}')
kubectl label node $NODE gpu=true

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: lubia-gpu
spec:
  containers:
  - image: luksa/kubia
    name: kubia
    ports:
    - containerPort: 8080
      protocol: TCP
  nodeSelector:
    gpu: "true"
EOF

#system namespace
kubectl get po -n kube-system

kubectl annotate pods kubia-label something.com/everything="this is quite nice and readable only from describe"
kubectl get pods kubia-label -o yaml
#...
#metadata:
#  annotations:
#    kubernetes.io/limit-ranger: 'LimitRanger plugin set: cpu request for container kubia'
#    something.com/everything: this is quite nice and readable only from describe
#...

kubectl create namespace wide-and-tried

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Namespace
metadata:
  name: tried-wide-and-ready-to-go
EOF

kubectl get ns
#NAME                         STATUS    AGE       ENVIRONMENT   SOMETHING
#default                      Active    1h                      
#kube-public                  Active    1h                      
#kube-system                  Active    1h                      
#tried-wide-and-ready-to-go   Active    21s                     
#wide-and-tried               Active    1m                      

kubectl delete po -l something

#switch default namespace
kubens wide-and-tried

kubectl delete ns wide-and-tried
kubectl delete all --all

kubectl config current-context
#what is this??
#kubectl config set-context ... --namespace

gcloud container clusters delete kubia
