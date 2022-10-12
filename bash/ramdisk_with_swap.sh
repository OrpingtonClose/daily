getconf PAGE_SIZE
sudo mkdir -p /var/swapmemory
cd /var/swapmemory
sudo dd if=/dev/zero of=swapfile bs=1M count=200000
sudo dd if=/dev/zero of=swapfile bs=1M count=200000
sudo mkswap swapfile
sudo swapon swapfile
sudo chmod 600 swapfile
echo "/var/swapmemory/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
free -m
sudo mkdir /mnt/ramdisk
sudo mount -t tmpfs -o rw,size=20G tmpfs /mnt/ramdisk
cd /mnt/ramdisk/
dmesg > file.txt
for n in {1..50}; do echo herp; done 
for n in {1..50}; do cat file.txt >> file1.txt; done 
for n in {1..50}; do cat file1.txt >> file2.txt; done 
for n in {1..50}; do cat file2.txt >> file3.txt; done 
for n in {1..50}; do cat file3.txt >> file4.txt; done 
sudo umount /mnt/ramdisk
sudo vi /etc/fstab #remove last line
sudo swapoff /var/swapmemory/swapfile 
sudo rm -rf /var/swapmemory/
