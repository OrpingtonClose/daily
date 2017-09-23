# centos
sudo su -
yum install -y yum-utils
REPO_FILE=/etc/yum/repos.d/bigtop.repo
mkdir $(dirname $REPO_FILE)

repo_file() {
  if [ "$2" == "new" ]
  then
    echo "$1" > $REPO_FILE 
  else
    echo "$1" >> $REPO_FILE
  fi
}

repo_file "[bigtop]" new
repo_file "name=Bigtop"
repo_file "enabled=1"
repo_file "gpgcheck=1"
repo_file "type=NONE"
repo_file "baseurl=https://bigtop-repos.s3.amazonaws.com/releases/1.1.0/centos/6/x86_64"
repo_file "gpgkey=https://dist.apache.org/repos/dist/release/bigtop/KEYS"

repocync -r bigtop
