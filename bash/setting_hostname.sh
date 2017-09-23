CURRENT_HOST=master1.cyrus.com  

echo "NETWORKING=yes\nHOSTNAME=$CURRENT_HOST" | sudo tee /etc/sysconfig/network

echo "`ifconfig eth0 | grep -o \"inet[ ][^ ]*\" | cut -d\" \" -f2` $CURRENT_HOST" | cat /etc/hosts - | sudo tee /etc/hosts

# this should return an ip
getent hosts $CURRENT_HOST

#dns server configuration not done
