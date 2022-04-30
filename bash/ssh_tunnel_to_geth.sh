EXTERNAL_IP=40.127.106.43
EXTERNAL_PORT=8545
INTERNAL_PORT=8545
EXTERNAL_USER=orpington

ssh -f -N -L $INTERNAL_PORT:localhost:$EXTERNAL_PORT $EXTERNAL_USER@$EXTERNAL_IP
curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}' http://$EXTERNAL_IP:$EXTERNAL_PORT
