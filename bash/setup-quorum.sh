sudo apt-get install git libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev jq -y

#https://tecadmin.net/install-go-on-ubuntu/
wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
sudo tar -xvf go1.10.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo mv go /usr/local/


echo export GOROOT=/usr/local/go | sudo tee -a /etc/profile | sh
echo export PATH=$GOROOT/bin:$PATH | sudo tee -a /etc/profile | sh
source ~/.profile

pushd .
git clone https://github.com/jpmorganchase/quorum.git
cd quorum
make all

#install constellation
curl -sSL https://get.haskellstack.org/ | sh
stack setup
popd
pushd .
git clone https://github.com/jpmorganchase/constellation.git
cd constellation
stack install

popd
pushd .
mkdir raft
cp ~/.local/bin/constellation-node raft/
cp quorum/build/bin/geth raft/
cp quorum/build/bin/bootnode raft/

cd raft
yes "" | ./constellation-node --generatekeys=cnode1
yes "" | ./constellation-node --generatekeys=cnode2
yes "" | ./constellation-node --generatekeys=cnode3
yes "" | ./constellation-node --generatekeys=cnode4

cat > constellation1.conf <<EOF
url = "http://127.0.0.1:9001/"
port = 9001
storage = "dir:$(pwd)/cnode_data/cnode1/"
socket = "$(pwd)/cnode_data/cnode1/constellation_node1.ipc"
othernodes = ["http://127.0.0.1:9002/", "http://127.0.0.1:9003/", "http://127.0.0.1:9004/"]
publickeys = ["$(pwd)/cnode1.pub"]
privatekeys = ["$(pwd)/cnode1.key"]
EOF

cat > constellation2.conf <<EOF
url = "http://127.0.0.1:9002/"
port = 9002
storage = "dir:$(pwd)/cnode_data/cnode2/"
socket = "$(pwd)/cnode_data/cnode1/constellation_node2.ipc"
othernodes = ["http://127.0.0.1:9001/"]
publickeys = ["$(pwd)/cnode2.pub"]
privatekeys = ["$(pwd)/cnode2.key"]
EOF

cat > constellation3.conf <<EOF
url = "http://127.0.0.1:9003/"
port = 9003
storage = "dir:$(pwd)/cnode_data/cnode3/"
socket = "$(pwd)/cnode_data/cnode1/constellation_node3.ipc"
othernodes = ["http://127.0.0.1:9001/"]
publickeys = ["$(pwd)/cnode3.pub"]
privatekeys = ["$(pwd)/cnode3.key"]
EOF

cat > constellation4.conf <<EOF
url = "http://127.0.0.1:9004/"
port = 9004
storage = "dir:$(pwd)/cnode_data/cnode4/"
socket = "$(pwd)/cnode_data/cnode1/constellation_node1.ipc"
othernodes = ["http://127.0.0.1:9001/"]
publickeys = ["$(pwd)/cnode4.pub"]
privatekeys = ["$(pwd)/cnode4.key"]
EOF

#In different terminal windows:
#./constellation-node constellation1.conf
NODE_BIN=$(find /home -path '*/raft/constellation-node' 2>/dev/null)
$NODE_BIN $(dirname $NODE_BIN)/constellation1.conf

#./constellation-node constellation2.conf
NODE_BIN=$(find /home -path '*/raft/constellation-node' 2>/dev/null)
$NODE_BIN $(dirname $NODE_BIN)/constellation2.conf

#./constellation-node constellation3.conf
NODE_BIN=$(find /home -path '*/raft/constellation-node' 2>/dev/null)
$NODE_BIN $(dirname $NODE_BIN)/constellation3.conf

#./constellation-node constellation4.conf
NODE_BIN=$(find /home -path '*/raft/constellation-node' 2>/dev/null)
$NODE_BIN $(dirname $NODE_BIN)/constellation4.conf

#returning to original terminal
for n in {1..4}
do cat enode_id_1
   ./bootnode -genkey enode_id_$n | tee /dev/fd/2 | sh
done

echo [ > static-nodes.json
for n in {1..4}
do  echo ===================================
    cat enode_id_$n
    echo
    echo \"enode://$(./bootnode -nodekey enode_id_$n -writeaddress)@127.0.0.1:2300$n?raftport=2100$n\" | tee -a static-nodes.json
    echo , >> static-nodes.json
done
CONTENT=$(head -n -1 static-nodes.json)
echo ${CONTENT}] > static-nodes.json

#create account
mkdir accounts
cd accounts
rm keystore/*
yes "" | ../geth --datadir . account new
cd keystore
ADDRESS=$(ls | rev | cut -c 1-40 | rev)
mv * key1

popd
pushd .

#https://github.com/jpmorganchase/quorum-examples/blob/master/examples/7nodes/genesis.json
cat - | jq ".alloc = {\"0x$ADDRESS\":{\"balance\":\"1000000000000000000000000000\"}}" > genesis.json <<EOF
{
  "alloc": {},
  "coinbase": "0x0000000000000000000000000000000000000000",
  "config": {
    "homesteadBlock": 0
  },
  "difficulty": "0x0",
  "extraData": "0x",
  "gasLimit": "0x7FFFFFFFFFFFFFFF",
  "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
  "nonce": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
EOF

for n in {1..3}
do mkdir -p qdata/node$n/{keystore,geth}
   cp static-nodes.json qdata/node$n/
   cp accounts/keystore/key1 qdata/node$n/keystore/
   cp enode_id_$n qdata/node$n/geth/nodekey
   ./geth --datadir qdata/node$n init genesis.json
done

#in new terminal
NODE_BIN=$(find /home -path '*/raft/constellation-node' 2>/dev/null)
PARDIR=$(dirname $NODE_BIN)
n=1
PRIVATE_CONFIG=$PARDIR/constellation$n.conf $PARDIR/geth --datadir $PARDIR/qdata$n/node$n --port 2300$n --raftport 2100$n --raft --ipcpath "$PARDIR/geth.ipc"
#Fatal: Raft-based consensus requires either (1) an initial peers list (in static-nodes.json) including this enode hash (95ddd5c7a848950654936ec704a10122f4cd56837a4fdaf50598d46c1966674c55d8acfd415d2e390c47a1ca124b04f261114b620a50347cdead39167b06b553), or (2) the flag --raftjoinexisting RAFT_ID, where RAFT_ID has been issued by an existing cluster member calling `raft.addPeer(ENODE_ID)` with an enode ID containing this node's enode hash.

NODE_BIN=$(find /home -path '*/raft/constellation-node' 2>/dev/null)
PARDIR=$(dirname $NODE_BIN)
n=2
PRIVATE_CONFIG=$PARDIR/constellation$n.conf $PARDIR/geth --datadir $PARDIR/qdata$n/node$n --port 2300$n --raftport 2100$n --raft --ipcpath "$PARDIR/geth.ipc"

NODE_BIN=$(find /home -path '*/raft/constellation-node' 2>/dev/null)
PARDIR=$(dirname $NODE_BIN)
n=3
PRIVATE_CONFIG=$PARDIR/constellation$n.conf $PARDIR/geth --datadir $PARDIR/qdata$n/node$n --port 2300$n --raftport 2100$n --raft --ipcpath "$PARDIR/geth.ipc"

