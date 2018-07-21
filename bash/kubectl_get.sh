#https://medium.com/@binduc/install-and-run-minikube-in-azure-linux-vm-47a12ade2d43
if [ -z "$(cat /proc/cpuinfo | grep 'vmx')" ]; then
  echo please enable virtualisation support
  exit 5
fi

if [ -z "$(dpkg -S virtualbox)" ]; then
  #https://stegard.net/2016/10/virtualbox-secure-boot-ubuntu-fail/
  echo \################ installing virtualbox
  if [ -z "$(grep -Fir https://download.virtualbox.org/virtualbox/debian /etc/apt/sources.list.d)" ]; then
    sudo apt-get install lsb-release -y
    echo deb https://download.virtualbox.org/virtualbox/debian $(lsb_release -c) contrib | sudo tee oracle.list
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    sudo apt-get update
  fi
  sudo apt-get install virtualbox-5.2
fi
LOCATION_SOMEWHERE_ELSE=L
OUTPUT_TO_LOCAL=O
SILENT=s
version=$(curl -${SILENT} https://storage.googleapis.com/kubernetes-release/release/stable.txt)

echo -e "\033[0;31m#############################\033[0m"
echo sudo curl -${LOCATION_SOMEWHERE_ELSE}${OUTPUT_TO_LOCAL} https://storage.googleapis.com/kubernetes-release/release/$version/bin/linux/amd64/kubectl | tee /dev/tty | sh -
echo -e "\033[0;31m#############################\033[0m"
echo sudo chmod +x ./kubectl | tee /dev/tty | sh -
echo -e "\033[0;31m#############################\033[0m"
echo sudo mv kubectl /usr/local/bin/ | tee /dev/tty | sh -
echo -e "\033[0;31m#############################\033[0m"

echo sudo wget https://github.com/kubernetes/minikube/releases/download/v0.25.0/minikube_0.25-0.deb | tee /dev/tty | sh -
echo -e "\033[0;31m#############################\033[0m"
echo sudo dpkg -i minikube_0.25-0.deb | tee /dev/tty | sh -
echo -e "\033[0;31m#############################\033[0m"

echo minikube start ########################################
minikube start
echo minikube status #######################################
minikube status

