if [[ -n "$(which testrpc)" ]]
then
  sudo apt-get update
  sudo apt-get install node -y
  sudo apt-get install npm -y
  sudo npm install -g ethereumjs-testrpc@beta
fi
testrpc 1> /dev/null 2>/dev/null &

if [[ -n "$(which Mist)" ]]
then
  wget https://github.com/ethereum/mist/releases/download/v0.8.3/Mist-linux64-0-8-3.deb
  sudo dpkg --install Mist-linux64-0-8-3.deb
  rm Mist-linux64-0-8-3.deb
fi

kill `lsof -iTCP:8545 -sTCP:LISTEN | awk '{if (NR > 1) print $2}'`

Mist --rpc localhost:8545 &
geth attach http://127.0.0.1:8545
