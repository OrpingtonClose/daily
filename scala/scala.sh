sudo apt-get install openjdk-9-jre-headless scala -y
echo "export JAVA_HOME=/usr/lib/jvm/java-9-openjdk-amd64" >> ~/.bashrc
echo "export SCALA_HOME=/usr/share/scala-2.11" >> ~/.bashrc
echo "export PATH=$PATH:$JAVA_HOME/bin:$SCALA_HOME/bin" >> ~/.bashrc
source ~/.barshrc
sudo update-alternatives --config javac
sudo apt-get install openjdk-9-jre-headless scala -y
which javac | ls $(cat -) -l | cut -d">" -f"2" | ls $(cat -) -l | cut -d">" -f"2" | dirname $(dirname $(cat -)) | export JAVA_HOME=$(cat -)
