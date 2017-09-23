# Mastering Ubuntu Server
# Setting up name resolution (DNS) with bind

sudo apt-get -y install bind9
systemctl start bind9
# /etc/init.d/bind9 start

(sed "/forwarders\s*{/,/}/s/\///g" "/etc/bind/named.conf.options" | sed "/0.0.0.0/s/0.0.0.0/8.8.8.8;\n8.8.4.4/") | sudo tee "/etc/bind/named.conf.options"

systemctl restart bind9
# /etc/init.d/bind9 restart

(cat /etc/resolv.conf) | sed '/nameserver/s/\([0-9]\{1,3\}[.]\)\{3\}[0-9]\{1,3\}/0.0.0.0/' | sudo tee /etc/resolv.conf

(echo -e "zone \"local.lan\" IN {\n$(printf ' %.s' {1..4})type master;\n$(printf ' %.s' {1..4})file \"/etc/bind/net.local.lan\";\n};" | cat /etc/bind/named.conf.local -) | sudo tee /etc/bind/named.conf.local
