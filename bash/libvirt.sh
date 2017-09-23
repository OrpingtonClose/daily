sudo apt-get install cpu-checker
sudo kvm-ok
sudo apt-get install libvirt-bin kvm bridge-utils qemu -y
sudo appuser $USER libvirtd
sudo apt-get install virt-manager
sudo virt-manager &

# Create the new disk image filename of size size and format fmt.
sudo qemu-img create -f qcow2 -o preallocation=metadata disk.qcow2 8G
sudo qemu-img check disk.qcow2
sudo qemu-img info disk.qcow2

sudo virt-install --connect qemu:///system --name cn_ubuntu --ram 1024 --disk mine.qcow2,format=qcow2 --network=bridge:virbr0,model=virtio --vnc --os-type=linux --cdrom ubuntu-16.04.3-server-amd64.iso --noautoconsole --keymap=en-us

