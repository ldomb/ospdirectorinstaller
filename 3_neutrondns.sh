source ~/stackrc
DNS=8.8.8.8
neutron subnet-update $(neutron subnet-list | awk '/start/ {print $2}') --dns-nameserver $DNS
