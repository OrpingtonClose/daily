git clone https://github.com/jpmorganchase/tessera.git

#java 8
sudo apt-get install -y openjdk-8-jdk

#maven
wget http://www-eu.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
tar xzf apache-maven-3.5.4-bin.tar.gz

#libsodium
# git clone https://github.com/jedisct1/libsodium --branch stable
# cd libsodium
# ./configure
# make && make check
# sudo make install
cd tessera
../apache-maven-3.5.4/bin/mvn install