#apt-cache show $(xsel -b) | grep ^Description-en | tee /dev/fd/2 | cut -d':' -f2 | xsel -b
sudo apt-get install xterm jq git  -y
sudo apt-get install libdb-dev -y      #Description-en: Berkeley Database Libraries [development]
sudo apt-get install libleveldb-dev -y #fast key-value storage library (development files)
sudo apt-get install libsodium-dev -y  #Network communication, cryptography and signaturing library - headers
sudo apt-get install zlib1g-dev -y     #Compression library - development
sudo apt-get install libtinfo-dev -y   #developer's library for the low-level terminfo library

BASEDIR=$PWD
RAFT=$BASEDIR/raft
mkdir $RAFT

#https://tecadmin.net/install-go-on-ubuntu/
wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
sudo tar -xvf go1.10.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo mv go /usr/local/

echo export GOROOT=/usr/local/go | sudo tee -a /etc/profile | sh
echo export PATH=$GOROOT/bin:$PATH | sudo tee -a /etc/profile | sh

cd $BASEDIR
git clone https://github.com/jpmorganchase/quorum.git
cd $BASEDIR/quorum
make all

#install constellation
cd $BASEDIR
curl -sSL https://get.haskellstack.org/ | sh
stack setup

cd $BASEDIR
git clone https://github.com/jpmorganchase/constellation.git
cd $BASEDIR/constellation
stack install

cp ~/.local/bin/constellation-node $RAFT/
cp $BASEDIR/quorum/build/bin/geth $RAFT/
cp $BASEDIR/quorum/build/bin/bootnode $RAFT/

cd $RAFT
yes "" | ./constellation-node --generatekeys=cnode1
yes "" | ./constellation-node --generatekeys=cnode2
yes "" | ./constellation-node --generatekeys=cnode3
yes "" | ./constellation-node --generatekeys=cnode4

declare -a OTHER=(2 3 4)
declare -a BROADCAST=(1)

#constellation configuration files
cd $BASEDIR
for n in {1..4}; do
  if [ "$n" -eq "1" ]; then
    OTHERNODES=$(echo [$(printf ", \"http://127.0.0.1:900%s/\"" "${OTHER[@]}")] | sed 's/, //')
  else
    OTHERNODES=$(echo [$(printf ", \"http://127.0.0.1:900%s/\"" "${BROADCAST[@]}")] | sed 's/, //')
  fi
cat > $RAFT/constellation$n.conf <<EOF
url = "http://127.0.0.1:900$n/"
port = 900$n
storage = "dir:$RAFT/cnode_data/cnode$n/"
socket = "$RAFT/cnode_data/cnode$n/constellation_node$n.ipc"
othernodes = $OTHERNODES
publickeys = ["$RAFT/cnode$n.pub"]
privatekeys = ["$RAFT/cnode$n.key"]
tls = "off"
verbosity = 3
EOF
done

for n in {1..4}
do xterm -fg white -bg black -e "$RAFT/constellation-node $RAFT/constellation$n.conf" &
done

for n in {1..4}
do $RAFT/bootnode -genkey $BASEDIR/enode_id_$n #| tee /dev/fd/2 | sh
done

echo [ > $BASEDIR/static-nodes.json
for n in {2..4}
do  echo ===================================
    cat $BASEDIR/enode_id_$n
    echo
    echo \"enode://$($RAFT/bootnode -nodekey $BASEDIR/enode_id_$n -writeaddress)@127.0.0.1:2300$n?raftport=2100$n\" | tee -a $BASEDIR/static-nodes.json
    echo , >> $BASEDIR/static-nodes.json
done
CONTENT=$(head -n -1 $BASEDIR/static-nodes.json)]

for n in {2..4}
do echo ${CONTENT} > $RAFT/cnode_data/cnode$n/static-nodes.json
done

#create account
mkdir $RAFT/accounts
rm $RAFT/accounts/keystore/*
PRIVKEY=$(openssl ecparam -name secp256k1 -genkey -noout | openssl ec -text -noout 2> /dev/null | grep priv -A 3 | tail -n -3 | tr -d '\n[:space:]:' | sed 's/^00//')
yes "" | $RAFT/geth --datadir $RAFT/accounts account import <(echo $PRIVKEY)
ADDRESS=$(ls $RAFT/accounts/keystore | head -1 | rev | cut -c 1-40 | rev)
mv $RAFT/accounts/keystore/* $RAFT/accounts/keystore/key1

#https://github.com/jpmorganchase/quorum-examples/blob/master/examples/7nodes/genesis.json
cat - | jq ".alloc = {\"0x$ADDRESS\":{\"balance\":\"1000000000000000000000000000\"}}" > $RAFT/genesis.json <<EOF
{
  "alloc": {},
  "coinbase": "0x0000000000000000000000000000000000000000",
  "config": {
    "homesteadBlock": 0
  },
  "difficulty": "0x00",
  "extraData": "0x",
  "gasLimit": "0x7FFFFFFFFFFFFFFF",
  "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
  "nonce": "0x00",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
EOF

for n in {1..4}
do 
   echo ======================node $n
   QUORUM_NODE=$RAFT/cnode_data/cnode$n
   rm -rf $QUORUM_NODE/{keystore,geth}
   echo mkdir -p $QUORUM_NODE/{keystore,geth} | tee /dev/fd/2 | sh
   echo cp $RAFT/accounts/keystore/key1 $QUORUM_NODE/keystore/  | tee /dev/fd/2 | sh
   echo cp $BASEDIR/enode_id_$n $QUORUM_NODE/geth/nodekey | tee /dev/fd/2 | sh
   echo $RAFT/geth --datadir $QUORUM_NODE init $RAFT/genesis.json | tee /dev/fd/2 | sh
done

#first node to be dynamically added to the network
for n in {2..4}
do 
   n_to_add=1
   DYNAMICALLY_ADDED_ENODE=$(echo \"enode://$($RAFT/bootnode -nodekey $BASEDIR/enode_id_$n_to_add -writeaddress)@127.0.0.1:2300$n_to_add?raftport=2100$n_to_add\")
   QUORUM_NODE=$RAFT/cnode_data/cnode$n   
   xterm -T "quorum geth $n static" -fg white -bg black -e "cd $RAFT; PRIVATE_CONFIG=$RAFT/constellation$n.conf $RAFT/geth --verbosity 2 --datadir $QUORUM_NODE --port 2300$n --raftport 2100$n --raft --ipcpath \"$QUORUM_NODE/geth.ipc\"; sleep 20" &
   echo "{\"jsonrpc\":\"2.0\",\"method\":\"raft_addPeer\",\"params\":[$DYNAMICALLY_ADDED_ENODE],\"id\":$n}" | nc -w 1 -U "$QUORUM_NODE/geth.ipc" | jq '.'
done

n=1
QUORUM_NODE=$RAFT/cnode_data/cnode$n
ADDITIONAL_FLAG='--raftjoinexisting 4'
xterm -T "quorum geth $n dynamic" -fg white -bg black -e "cd $RAFT; PRIVATE_CONFIG=$RAFT/constellation$n.conf $RAFT/geth $ADDITIONAL_FLAG --verbosity 2 --datadir $QUORUM_NODE --port 2300$n --raftport 2100$n --raft --ipcpath \"$QUORUM_NODE/geth.ipc\"; sleep 20" &

#check if all nodes have the same peer list
for n in {1..4}
do QUORUM_NODE=$RAFT/cnode_data/cnode$n
   echo node$n $(sha1sum <(echo "{\"jsonrpc\":\"2.0\",\"method\":\"raft_cluster\",\"params\":[],\"id\":1}" | nc -w 1 -U "$QUORUM_NODE/geth.ipc" | jq '.result | sort_by(.raftId)') | awk '{print $1}')
done

#remove peer #3
n=1
QUORUM_NODE=$RAFT/cnode_data/cnode$n
echo "{\"jsonrpc\":\"2.0\",\"method\":\"raft_removePeer\",\"params\":[3],\"id\":1}" | nc -w 1 -U "$QUORUM_NODE/geth.ipc"

for n in {1..4}
do QUORUM_NODE=$RAFT/cnode_data/cnode$n
   echo node$n $(sha1sum <(echo "{\"jsonrpc\":\"2.0\",\"method\":\"raft_cluster\",\"params\":[],\"id\":1}" | nc -w 1 -U "$QUORUM_NODE/geth.ipc" | jq '.result | sort_by(.raftId)') | awk '{print $1}')
done

n=1
QUORUM_NODE=$RAFT/cnode_data/cnode$n
echo Block number: $(($(echo "{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}" | nc -w 1 -U "$QUORUM_NODE/geth.ipc" | jq -r '.result')))
