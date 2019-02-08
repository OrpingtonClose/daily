#unfinished
#https://developer.holochain.org/start.html
#install nodejs
#install rust
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly-2018-12-26
rustup target add wasm32-unknown-unknown
#zeromq
echo "deb http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/Debian_9.0/ ./" | sudo tee -a /etc/apt/sources.list
wget https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/Debian_9.0/Release.key -O- | sudo apt-key add
sudo apt-get install libzmq3-dev

wget https://github.com/holochain/n3h/archive/v0.0.3.tar.gz
tar xzf v0.0.3.tar.gz
rm -r v0.0.3.tar.gz
cd n3h-0.0.3
npm install
npm run bootstrap

cd ..

wget https://github.com/holochain/holochain-rust/releases/download/v0.0.3/cmd-v0.0.3-x86_64-ubuntu-18-04.tar.gz
tar xzf cmd-v0.0.3-x86_64-ubuntu-18-04.tar.gz
rm -r cmd-v0.0.3-x86_64-ubuntu-18-04.tar.gz
cp cmd-v0.0.3-x86_64-unknown-linux-gnu/hc .
rm -r cmd-v0.0.3-x86_64-unknown-linux-gnu
./hc --version

wget https://github.com/holochain/holochain-rust/releases/download/v0.0.3/container-v0.0.3-x86_64-ubuntu-18-04.tar.gz
tar xzf container-v0.0.3-x86_64-ubuntu-18-04.tar.gz
rm -r container-v0.0.3-x86_64-ubuntu-18-04.tar.gz
cp container-v0.0.3-x86_64-unknown-linux-gnu/holochain_container .
./holochain_container --version

