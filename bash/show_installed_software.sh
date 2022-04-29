#show installed software
sudo apt list --installed | grep '\[installed\]' | awk -v row=2 '{split($0,a,"/"); print a[1];}' | xargs -n4
