# sudo apt-get update
# sudo apt-get install curl apt-transport-https lsb-release -y
# curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
#     gpg --dearmor | \
#     sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
# AZ_REPO=$(lsb_release -cs)
# echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
#     sudo tee /etc/apt/sources.list.d/azure-cli.list
# sudo apt-get update
# sudo apt-get install azure-cli -y
# az login

# az network nsg create --resource-group azuremolchapter5 --name remotensg
# az network nsg rule create \
# --resource-group azuremolchapter5 \
# --nsg-name remotensg \
# --name allowssh \
# --protocol tcp \
# --priority 100 \
# --destination-port-range 22 \
# --access allow

# az network vnet subnet create \
# --resource-group azuremolchapter5 \
# --vnet-name vnetmol \
# --name remotesubnet \
# --address-prefix 10.0.2.0/24 \
# --network-security-group remotensg

# az vm create \
# --resource-group azuremolchapter5 \
# --name webvm \
# --nics webvnic \
# --image UbuntuLTS \
# --size Standard_B1ms \
# --admin-username azuremol \
# --generate-ssh-keys

# az vm create \
# --resource-group azuremolchapter5 \
# --name remotevm \
# --vnet-name vnetmol \
# --subnet remotesubnet \
# --nsg remotensg \
# --public-ip-address remotepublicip \
# --image UbuntuLTS \
# --size Standard_B1ms \
# --admin-username azuremol \
# --generate-ssh-keys
# --nics webvnic \
# --image UbuntuLTS \
# --size Standard_B1ms \
# --admin-username azuremol \
# --generate-ssh-keys

# eval $(ssh-agent)
# ssh-add

# ssh -A azuremol@40.85.170.40
# ssh 10.0.1.4
# sudo apt-get update && sudo apt install -y lamp-server^

GROUP=TestRG
LOCATION=eastus
VN=VNet1
SUB=FrontEnd
SUB_GATEWAY=GatewaySubnet
PUBLIC_IP=VNet1GWIP
GATEWAY=VNet1GW

az group create --name $GROUP --location $LOCATION

az network vnet create -g $GROUP -n $VN -l $LOCATION \
           --address-prefixes '192.168.0.0/16' \
           --subnet-name $SUB \
           --subnet-prefixes 192.168.1.0/24

az network vnet subnet create -n $SUB_GATEWAY -g $GROUP \
           --vnet-name $VN \
           --address-prefix 192.168.255.0/27

az network public-ip create -n $PUBLIC_IP -g $GROUP \
            --allocation-method Dynamic

#takes 45 minutes
az network vnet-gateway create -n $GATEWAY -l $LOCATION -g $GROUP \
            --public-ip-address $PUBLIC_IP \
            --vnet $VN \
            --gateway-type Vpn \
            --sku VpnGw1 \
            --vpn-type RouteBased

az network vnet-gateway show -n $GATEWAY -g $GROUP | jq
az network public-ip show -n $PUBLIC_IP  -g $GROUP | jq -r '.ipAddress' | tee /dev/fd/1 | xsel -b

#https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site-linux
#https://www.digitalocean.com/community/tutorials/how-to-set-up-an-ikev2-vpn-server-with-strongswan-on-ubuntu-18-04-2

sudo apt-get install strongswan-ikev2 -y
sudo apt-get install strongswan-plugin-eap-tls -y
sudo apt-get install libstrongswan-standard-plugins -y
#sudo apt-get install strongswan-pki -y ??

mkdir -p pki/{private,cacerts,certs}

#generate CA certificate
ipsec pki --gen --outform pem > pki/private/ca-key.pem
ipsec pki --self --in pki/private/ca-key.pem --dn "CN=VPN CA" --ca --outform pem > pki/cacerts/ca-cert.pem
openssl x509 -in pki/cacerts/ca-cert.pem -outform der | base64 -w0

PASSWORD="password"
USERNAME="client"
#pki/private/server-key.pem
ipsec pki --gen --outform pem > pki/private/server-key.pem
ipsec pki --pub --in pki/private/server-key.pem \
  | ipsec pki --issue --cacert pki/cacerts/ca-cert.pem \
                      --cakey pki/private/ca-key.pem \
                      --dn "CN=${USERNAME}" --san "${USERNAME}" \
                      --flag clientAuth --outform pem > pki/certs/server-cert.pem

# ipsec pki --gen --outform pem > "${USERNAME}Key.pem"
# ipsec pki --pub --in "${USERNAME}Key.pem" \
#   | ipsec pki --issue --cacert caCert.pem \
#                       --cakey caKey.pem \
#                       --dn "CN=${USERNAME}" --san "${USERNAME}" \
#                       --flag clientAuth --outform pem > "${USERNAME}Cert.pem"

#bundle file - what is this for?
#openssl pkcs12 -in "${USERNAME}Cert.pem" -inkey "${USERNAME}Key.pem" -certfile caCert.pem -export -out "${USERNAME}.p12" -password "pass:${PASSWORD}"
openssl pkcs12 -in pki/certs/server-cert.pem -inkey pki/private/ca-key.pem -certfile pki/cacerts/ca-cert.pem -export -out "${USERNAME}.p12" -password "pass:${PASSWORD}"

#Client address pool: 172.16.201.0/24
grep -v '^-' pki/certs/server-cert.pem | tr -d '\n' | xsel -b
sudo cp -r pki/* /etc/ipsec.d/
#https://serverfault.com/questions/840920/how-connect-a-linux-box-to-an-azure-point-to-site-gateway
tree pki
tree /etc/ipsec.d


ls /etc/ipsec.d/


###################################
#https://serverfault.com/questions/840920/how-connect-a-linux-box-to-an-azure-point-to-site-gateway
###################################
sudo apt-get install strongswan-ikev2 strongswan-plugin-eap-tls
# in Ubuntu 16.04 install libstrongswan-standard-plugins for p12 keypair container support
sudo apt-get install libstrongswan-standard-plugins
# sudo sed -i 's/\sload =.*/ load = no/g' /etc/strongswan.d/charon/openssl.conf
# sudo sed -i 's/\sload =.*/ load = no/g' /etc/strongswan.d/charon/{af-alg,ctr,gcrypt}.conf

# Generate CA
ipsec pki --gen --outform pem > caKey.pem
ipsec pki --self --in caKey.pem --dn "CN=VPN CA" --ca --outform pem > caCert.pem
# Print CA certificate in base64 format, supported by Azure portal. Will be used later in this document.
openssl x509 -in caCert.pem -outform der | base64 -w0 ; echo

# Generate user's certificate and put it into p12 bundle.
export PASSWORD="password"
export USERNAME="client"
ipsec pki --gen --outform pem > "${USERNAME}Key.pem"
ipsec pki --pub --in "${USERNAME}Key.pem" | ipsec pki --issue --cacert caCert.pem --cakey caKey.pem --dn "CN=${USERNAME}" --san "${USERNAME}" --flag clientAuth --outform pem > "${USERNAME}Cert.pem"
# Generate p12 bundle
openssl pkcs12 -in "${USERNAME}Cert.pem" -inkey "${USERNAME}Key.pem" -certfile caCert.pem -export -out "${USERNAME}.p12" -password "pass:${PASSWORD}"

#download "Download CPN client" from portal
sudo unzip -j ~/Downloads/VNet1GW.zip Generic/VpnServerRoot.cer -d /etc/ipsec.d/cacerts
#verification
#openssl x509 -inform der -in /etc/ipsec.d/cacerts/VpnServerRoot.cer -text -noout

DNS=$(unzip -p ~/Downloads/VNet1GW.zip Generic/VpnSettings.xml | grep VpnServer | cut -d'>' -f2 | cut -d'<' -f1)

sudo cp client.p12 /etc/ipsec.d/private/


code -r /etc/ipsec.conf
#big hole
code -r /etc/strongswan.d/charon/kernel-netlink.conf
sudo code -r /etc/ipsec.secrets

sudo ipsec restart
sudo ipsec up azure


this:
https://docs.microsoft.com/en-us/azure/vpn-gateway/point-to-site-vpn-client-configuration-azure-cert#installlinux

