#centos
sudo su -
yum install -y gcc gcc-c++ openssl-devel make cmake

sudo yum install java-1.7.0-openjdk-devel

PACKAGE=apache-maven-3.3.9-bin.tar.gz
wget mirrors.gigenet.com/apache/maven/maven-3/3.3.9/binaries/$PACKAGE
tar zxf $PACKAGE -C /opt/
rm -f $PACKAGE

export JAVA_HOME=$(dirname $(dirname $(readlink -f "$(which java)")))
export M3_HOME=/opt/apache-maven-3.3.9
export PATH=$PATH:$JAVA_HOME/bin:$M3_HOME/bin

PACKAGE=apache-maven-3.3.9-bin.tar.gz
wget https://github.com/google/protobuf/releases/download/v2.5.0/$PACKAGE
tar xzf $PACKAGE -C /opt 
rm $PACKAGE
cd /opt/protobuf-2.5.0
./configure
make; make install

PACKAGE=hadoop-2.8.1-src.tar.gz
wget http://ftp.ps.pl/pub/apache/hadoop/common/hadoop-2.8.1/$PACKAGE
tar xzf $PACKAGE -C /opt

cd /opt/hadoop-2.8.1-src

mvn package -Pdist,native -DskipTests -Dtar


