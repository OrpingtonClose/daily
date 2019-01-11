BASEDIR=$PWD
IBFT=$BASEDIR/ibft

mkdir -p $BASEDIR/go/src/github.com/getamis
cd $BASEDIR/go/src/github.com/getamis
git clone https://github.com/getamis/istanbul-tools.git
export GOPATH=~/go
go get github.com/getamis/istanbul-tools/cmd/istanbul

mkdir $IBFT
mv ~/go/bin/istanbul $IBFT/

cd $BASEDIR
git clone https://github.com/jpmorganchase/quorum.git
cd $BASEDIR/quorum
make all
cp $BASEDIR/quorum/build/bin/geth $IBFT/

cd $IBFT/

mkdir $IBFT/accounts
rm $IBFT/accounts/keystore/*
PRIVKEY=$(openssl ecparam -name secp256k1 -genkey -noout | openssl ec -text -noout 2> /dev/null | grep priv -A 3 | tail -n -3 | tr -d '\n[:space:]:' | sed 's/^00//')
yes "" | geth --datadir $IBFT/accounts account import <(echo $PRIVKEY)
ADDRESS=$(ls $IBFT/accounts/keystore | head -1 | rev | cut -c 1-40 | rev)
mv $IBFT/accounts/keystore/* $IBFT/accounts/keystore/key1

echo $PRIVKEY
echo $ADDRESS

#creates the genesis block, static-nodes.json and validators
$IBFT/istanbul setup --num 4 --nodes --verbose --save

JSON=$(cat $IBFT/genesis.json | jq ".alloc += {\"$ADDRESS\":{\"balance\": \"0x446c3b15f9926687d2c40534fdb564000000000000\"}}")
echo $JSON > $IBFT/genesis.json

for n in $(ls $IBFT | grep '[0-3]')
do cp $IBFT/$n/nodekey $IBFT/enode_id_$(($n+1))
   rm -r $IBFT/$n
   SUBSTITUTION_STUB='s/0.0.0.0:30303/127.0.0.1:2300'
   SUBSTITUTION=$SUBSTITUTION_STUB$n/
   sed -i "$(($n+2)) $SUBSTITUTION" $IBFT/static-nodes.json
done

for n in {1..6}
do mkdir -p $IBFT/qdata/node$n/geth
   cp $IBFT/static-nodes.json $IBFT/qdata/node$n/
   $IBFT/geth --datadir $IBFT/qdata/node$n init $IBFT/genesis.json
   if [ "$n" -lt "5" ]; then
       cp $IBFT/enode_id_$n $IBFT/qdata/node3/geth/nodekey
   fi
done

mkdir -p $IBFT/qdata/node1/keystore
cp $IBFT/accounts/keystore/key1 $IBFT/qdata/node1/keystore

for n in {1..6}
do
if [ "$n" -lt "5" ]; then
  ISTANBUL='--mine --etherbase 0x$ADDRESS --istanbul.requesttimeout 5000 --istanbul.blockperiod 10'
else
  ISTANBUL=
fi
  xterm -T "quorum geth $n static" -fg white -bg black -e "cd $IBFT/qdata/node$n; $IBFT/geth --datadir $IBFT/qdata/node$n --port 2300$(($n-1)) --ipcpath \"$IBFT/qdata/node$n/geth.ipc\" $ISTANBUL console; sleep 20" &
done
