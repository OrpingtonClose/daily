
gcloud auth login
gcloud config set project $(gcloud projects list | awk '/avid/ {print $1}')
gcloud config set compute/zone europe-west1
gcloud container clusters create kubia --num-nodes 5 --machine-type f1-micro
helm init
kubectl get pods -n kube-system | grep tiller

#helm install --name my-release stable/dask
#Error: release my-release failed: namespaces "default" is forbidden: User "system:serviceaccount:kube-system:default" cannot get namespaces in the namespace "default": Unknown user "system:serviceaccount:kube-system:default"



#https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config list | awk '/^acc/ {print $3}')

#https://stackoverflow.com/questions/48556971/unable-to-install-kubernetes-charts-on-specified-namespace
cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: tiller
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

kubectl create serviceaccount tiller -n kube-system

cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: tiller
  apiGroup: rbac.authorization.k8s.io
EOF
    
kubectl edit deployment -n kube-system tiller-deploy
# spec.template.spec.serviceAccountName: tiller

##https://github.com/dask/dask-kubernetes/issues/55
cat <<EOF | helm install --debug --name my-release stable/dask -f -
worker:
  env:
  - name: EXTRA_CONDA_PACKAGES
    value: numba xarray dask distributed netcdf4 zarr gcsfs cartopy anaconda -c
  - name: EXTRA_PIP_PACKAGES
    value: s3fs dask-ml xshape dask-kubernetes fusepy lz4 --upgrade
    GCSFUSE_BUCKET: rhg-data
jupyter:
  env:
  - name: EXTRA_CONDA_PACKAGES
    value: numba xarray dask distributed netcdf4 zarr gcsfs cartopy anaconda -c
  - name: EXTRA_PIP_PACKAGES
    value: s3fs dask-ml xshape dask-kubernetes fusepy lz4 --upgrade
    GCSFUSE_BUCKET: rhg-data
EOF

#helm install --name my-release stable/dask
#Jupyter notebook
#Dask dashboard
#Dask Client connection
echo -e "Jupyter notebook: http://$(kubectl get svc my-release-dask-jupyter -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):80\nDask dashboard: http://$(kubectl get svc my-release-dask-scheduler -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):80\nDask Client connection: http://$(kubectl get svc my-release-dask-scheduler -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8786"
#echo http://$(kubectl get svc my-release-dask-scheduler -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):80
#echo http://$(kubectl get svc my-release-dask-scheduler -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8786

#https://cloud.google.com/kubernetes-engine/docs/how-to/resizing-a-cluster
#jupyter is not responsive with only two nodes? Perhaps resizing will help.
#had to upgrade from trial account
gcloud container clusters resize kubia --size 8
kubectl scale deployment my-release-dask-worker --replicas=12

#https://github.com/dask/distributed/issues/1830
#sudo -H pip3 install lz4
#lz4 wasn't on the nodes in the cluster - worker or master?
gcloud containers clusters get-credentials kubia
SCHEDULER=$(kubectl get svc my-release-dask-scheduler -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8786
python3 -c "import dask.distributed; dask.distributed.Executor('$SCHEDULER').get_versions(check=True)"
sudo -H pip3 uninstall tornado
sudo -H pip3 install tornado==4.5.1
sudo -H pip3 install blosc


#while using jupyter, an 403 error is reported
#https://github.com/dask/dask-kubernetes/issues/55
#cat <<EOF | kubectl create -f -
#apiVersion: 

#permissive binding?
#https://kubernetes.io/docs/reference/access-authn-authz/rbac/#permissive-rbac-permissions
kubectl create clusterrolebinding permissive-binding \
	  --clusterrole=cluster-admin \
	  --user=admin \
	  --user=kubelet \
	  --group=system:serviceaccounts

#distributed.protocol.core - CRITICAL - Failed to deserialize
#Traceback (most recent call last):
#  File "/usr/local/lib/python3.6/dist-packages/distributed/protocol/core.py", line 122, in loads
#      value = _deserialize(head, fs, deserializers=deserializers)
#        File "/usr/local/lib/python3.6/dist-packages/distributed/protocol/serialize.py", line 235, in deserialize
#	    dumps, loads = families[name]
#	    KeyError: None
#	    T

#decided on a different way of doing this
#helm repo add pangeo https://pangeo-data.github.io/helm-chart/
#orpington@orpington-pc:~/Desktop/dask-gke$ kubectl get nodes --output=json --context gke_avid-winter-211921_europe-west1_kubia
#Unable to connect to the server: x509: certificate signed by unknown authority

#trying pangeo:
#https://github.com/pangeo-data/helm-chart

#http://pangeo.io/setup_guides/cloud.html#step-one-install-the-necessary-software
EMAIL=pawlicki.jakub@outlook.com

kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$EMAIL
kubectl create serviceaccount tiller --namespace=kube-system
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
kubectl --namespace=kube-system patch deployment tiller-deploy --type=json \
	      --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'
#https://github.com/rabernat/dask_distributed_demo/blob/master/notebooks/petascale_postprocessing_presentation.ipynb
#https://dask.pydata.org/en/latest/setup/kubernetes-helm.html
