wget https://releases.hashicorp.com/vagrant/2.0.0/vagrant_2.0.0_x86_64.deb
sudo dpkg -i vagrant_2.0.0_x86_64.deb
rm vagrant_2.0.0_x86_64.deb
sudo apt-get install virtualbox -y
git clone https://github.com/concord/getting-started.git concord-getting-started
cd concord-getting-started
./bootstrap_vagrant.sh
vagrant ssh


