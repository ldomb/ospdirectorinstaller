cd /home/stack/images
virt-customize -a overcloud-full.qcow2 --edit /etc/default/grub:s/net.ifnames=0/net.ifnames=1/
virt-customize -a overcloud-full.qcow2 --edit /root/anaconda-ks.cfg:s/net.ifnames=0/net.ifnames=1/
virt-customize --root-password password:laurent -a overcloud-full.qcow2

