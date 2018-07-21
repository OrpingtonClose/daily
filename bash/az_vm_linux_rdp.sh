#https://docs.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop
group_name=azvmrdpgrp$(uuidgen | cut -c 1-7 | tr '[:upper:]' '[:lower:]')
vm_name=azvmrdp$(uuidgen | cut -c 1-7 | tr '[:upper:]' '[:lower:]')
location=westus
ad_user=orpington
az group create --name $group_name --location $location
az vm create -g $group_name -n $vm_name --image UbuntuLTS --admin-username $ad_user --generate-ssh-keys
#microsoft is investigating problems that this caused. 

