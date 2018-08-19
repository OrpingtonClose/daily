gcloud auth login
PROJECT=$(gcloud projects list | awk 'FNR==2 {print $1}')
gcloud config set project $PROJECT
gcloud config set compute/zone europe-west1
gcloud container clusters create kubia --num-nodes 2 --machine-type f1-micro
gcloud container clusters get-credentials kubia

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: default
spec:
  containers:
  - name: service
    image: nginx
    ports:
    - containerPort: 80
    env:
    - name: SOME_ENV_VAR
      value: Hello World
EOF

ReplicaSet ensures that a specified number of pod replicas are running at any given time.

cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-service
  template:
    metadata:
      labels:
        app: my-service
    spec:
      containers:
      - name: service
        image: nginx
EOF

kubectl scale replicaset my-service --replicas=10

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: my-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF

kubectl run --rm -it --image=alpine my-test
apk -U add curl
curl my-service
curl my-service.default
curl my-service.default.svc
curl my-service.default.svc.cluster
curl my-service.default.svc.cluster.local

kubectl delete service my-service

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  selector:
    app: my-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF

kubectl get svc
curl $(kubectl get svc my-service | awk '{print $4}' | tail -1)
HOST=`nslookup $(kubectl get svc my-service | awk '{print $4}' | tail -1) | grep name | cut -d'=' -f2 | sed 's/.$//' | sed 's/^.//'`

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: service2
spec:
  type: ClusterIP
  selector:
    app: my-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF

cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host $HOST
    http:
      paths:
      - backend:
        serviceName: my-service
	servicePort: 80
  - host: $HOST
    http:
      paths:
      - backend:
        serviceName: service2
	servicePort: 80
EOF

cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-deployment
  template:
    metadata:
      labels:
        app: my-deployment
    spec:
      containers:
      - name: my-dep
        image: luksa/kubia
EOF

kubectl scale deployments my-deployments --replicas=7
kubectl edit deployment my-deployment

kubectl rollout undo deployment/my-deployment

#https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: herpvolume
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi
EOF

#sudo snap install helm
#kubectl config view > /home/orpington/snap/helm/common/kube/config
#sudo helm init
#kubectl config view | sudo tee /root/snap/helm/common/kube/config
#sudo helm init
#
#
