export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install google-cloud-sdk
gcloud auth login
gcloud config set project $(gcloud projects list | awk 'NF=1 && FNR==2')
gcloud container clusters create kubia --machine-type f1-micro --num-nodes 2 --zone europe-west1
gcloud container clusters delete $(gcloud container clusters list | awk 'NF=1 && FNR==2') --region $(gcloud container clusters list | awk 'FNR==2 {print $2}')

