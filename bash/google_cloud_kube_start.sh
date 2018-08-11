export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install google-cloud-sdk
gcloud auth login
gcloud config set project $(gcloud projects list | awk 'NF=1 && FNR==2')
gcloud container clusters create kubia --machine-type f1-micro --num-nodes 2 --zone europe-west1

#get all nodes in a cluster
kubectl get nodes

NODE=$(kubectl get nodes | awk 'NF = 1 && FNR==2')

#ssh into node
gcloud compute ssh $NODE

#get node info
kubectl describe node $NODE

#tab completion
source <(kubectl completion bash)
#with alias for kubectl
source <(kubectl completion bash | sed s/kubectl/k/g)

#run container on                                      ReplicationController
kubectl run kubia --image=orpington/kubia --port=8080  --generator=run/v1

#open replicationcontroller externally
kubectl expose rc kubia --type=LoadBalancer --name=kubia-http

kubectl get replicationcontrollers

kubectl scale rc kubia --replicas=3

kubectl cluster-info
gcloud container clusters describe kubia
#gcloud container clusters delete $(gcloud container clusters list | awk 'NF=1 && FNR==2') --region $(gcloud container clusters list | awk 'FNR==2 {print $2}')

#failure. couldn't get the node app to work
