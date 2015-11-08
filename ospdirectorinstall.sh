#!/bin/bash
######## RHN CONFIG ######################################################
RHNUSER=YOURUSER
RHNPASSWORD=YOURPASSWORD
POOLID=YOURPOOLID
######## HOSTNAME CONFIG #################################################
MGMT_IP=192.168.1.34                                                    
FQDN=ospdirector.local.domb.com                                          
SHORT=ospdirector                                                        
######## Stack User Password #############################################
PASSWD=redhat                                                            
######## undercloud.conf #################################################
# IP information for the interface on the Undercloud that will be        
# handling the PXE boots and DHCP for Overcloud instances.  The IP       
# portion of the value will be assigned to the network interface         
# defined by local_interface, with the netmask defined by the prefix     
# portion of the value. (string value)                                   
LOCAL_IP=192.168.2.2/24
# Virtual IP address to use for the public endpoints of Undercloud      
# services. (string value)
UNDERCLOUD_PUBLIC_VIP=192.168.2.3
# Virtual IP address to use for the admin endpoints of Undercloud
# services. (string value)
UNDERCLOUD_ADMIN_VIP=192.168.2.4
# Certificate file to use for OpenStack service SSL connections.
# (string value)
#UNDERCLOUD_SERVICE_CERTIFICATE=undercloud.pem --> This is not working yet
# Network interface on the Undercloud that will be handling the PXE
# boots and DHCP for Overcloud instances. (string value)
LOCAL_IFACE=enp2s4
# Network that will be masqueraded for external access, if required.
# This should be the subnet used for PXE booting. (string value)
MASQUERADE_NETWORK=192.168.2.0/24
# Start of DHCP allocation range for PXE and DHCP of Overcloud
# instances. (string value)
DHCP_START=192.168.2.80
# End of DHCP allocation range for PXE and DHCP of Overcloud
# instances. (string value)
DHCP_END=192.168.2.104
# Network CIDR for the Neutron-managed network for Overcloud
# instances. This should be the subnet used for PXE booting. (string
# value)
NETWORK_CIDR=192.168.2.0/24
# Network gateway for the Neutron-managed network for Overcloud
# instances. This should match the local_ip above when using
# masquerading. (string value)
NETWORK_GATEWAY=192.168.2.1
# Network interface on which discovery dnsmasq will listen.  If in
# doubt, use the default value. (string value)
DISCOVERY_INTERFACE=br-ctlplane
# Temporary IP range that will be given to nodes during the discovery
# process.  Should not overlap with the range defined by dhcp_start
# and dhcp_end, but should be in the same network. (string value)
DISCOVERY_IP_START=192.168.2.200
DISCOVERY_IP_END=192.168.2.220
# Whether to run benchmarks when discovering nodes. (boolean value)
DISCOVERY_RUNBENCH_BOOL=false
# Whether to enable the debug log level for Undercloud OpenStack
# services. (boolean value)
UNDERCLOUD_DEBUG_BOOL=true
############################################################################


echo $"
   ___  ____  ____     _ _               _             
  / _ \/ ___||  _ \ __| (_)_ __ ___  ___| |_ ___  _ __ 
 | | | \___ \| |_) / _  | |  __/ _ \/ __| __/ _ \|  __|
 | |_| |___) |  __/ (_| | | | |  __/ (__| || (_) | |   
  \___/|____/|_|   \__ _|_|_|  \___|\___|\__\___/|_|   
  _           _        _ _                             
 (_)_ __  ___| |_ __ _| | | ___ _ __                   
 | |  _ \/ __| __/ _  | | |/ _ \  __|                  
 | | | | \__ \ || (_| | | |  __/ |                     
 |_|_| |_|___/\__\__ _|_|_|\___|_|                     
                                                       
 +-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+
 |b|y| |L|a|u|r|e|n|t| |D|o|m|b|
 +-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+
"

echo "Creating user stack"
useradd stack
echo $PASSWD | passwd stack --stdin
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack


echo -e "$MGMT_IP\t\t$FQDN\t$SHORT" >> /etc/hosts

hostnamectl set-hostname $FQDN
hostnamectl set-hostname --transient $FQDN
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf

echo "Registering System"
subscription-manager register --username=$RHNUSER --password=$RHNPASSWORD
subscription-manager attach --pool=$POOLID
subscription-manager repos --disable='*'
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-optional-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-openstack-7.0-rpms --enable=rhel-7-server-openstack-7.0-director-rpms

echo "Updating system"
yum install screen libguestfs-tools-c -y && update -y

mkdir -p /etc/pki/instack-certs
mkdir -p /home/stack/{images,templates} 
chown -R stack.stack /home/stack

echo "Installing  python-rdomanager-oscplugin screen"
sudo -H -u stack bash -c 'sudo yum install -y python-rdomanager-oscplugin screen' 
sudo -H -u stack bash -c 'sudo cp /usr/share/instack-undercloud/undercloud.conf.sample ~/undercloud.conf' 
chown -R stack.stack /home/stack/undercloud.conf
cd /home/stack

 
#echo "Create Certs"
#openssl genrsa -out privkey.pem 2048
#sudo openssl req -new -x509 -key privkey.pem -out cacert.pem -days 365
#cat /home/stack/cacert.pem privkey.pem > /home/stack/undercloud.pem 
#chown stack.stack /home/stack/{undercloud.pem,cacert.pem,privkey.pem}
#cp /home/stack/undercloud.pem /etc/pki/instack-certs/
#semanage fcontext -a -t haproxy_exec_t "/etc/pki/instack-certs(/.*)?"
#restorecon -Rv /etc/pki/instack-certs 

echo "Modifying undercloud.conf"
sudo -H -u stack bash -c "sed -i 's|#image_path = \.|image_path = /home/stack/images|g' /home/stack/undercloud.conf" 
sudo -H -u stack bash -c "sed -i 's|#local_ip = 192.0.2.1/24|local_ip = $LOCAL_IP|g' /home/stack/undercloud.conf" 
sudo -H -u stack bash -c "sed -i 's|#undercloud_public_vip = 192.0.2.2|undercloud_public_vip = $UNDERCLOUD_PUBLIC_VIP|g' /home/stack/undercloud.conf" 
sudo -H -u stack bash -c "sed -i 's|#undercloud_admin_vip = 192.0.2.3|undercloud_admin_vip = $UNDERCLOUD_ADMIN_VIP|g' /home/stack/undercloud.conf" 
#sudo -H -u stack bash -c "sed -i 's|#undercloud_service_certificate =|undercloud_service_certificate = $UNDERCLOUD_SERVICE_CERTIFICATE|g' /home/stack/undercloud.conf" 
sudo -H -u stack bash -c "sed -i 's|#local_interface = eth1|local_interface = $LOCAL_IFACE|g' /home/stack/undercloud.conf" 
sudo -H -u stack bash -c "sed -i 's|#masquerade_network = 192.0.2.0/24|masquerade_network = $MASQUERADE_NETWORK|g' /home/stack/undercloud.conf" 
sudo -H -u stack bash -c "sed -i 's|#dhcp_start = 192.0.2.5|dhcp_start = $DHCP_START|g' /home/stack/undercloud.conf" 
sudo -H -u stack bash -c "sed -i 's|#dhcp_end = 192.0.2.24|dhcp_end = $DHCP_END|g' /home/stack/undercloud.conf" 
sudo -H -u stack bash -c "sed -i 's|#network_cidr = 192.0.2.0/24|network_cidr = $NETWORK_CIDR|g' /home/stack/undercloud.conf"
sudo -H -u stack bash -c "sed -i 's|#network_gateway = 192.0.2.1|network_gateway = $NETWORK_GATEWAY|g' /home/stack/undercloud.conf"
#sudo -H -u stack bash -c "sed -i 's|#discovery_interface = br-ctlplane|discovery_interface = $DISCOVERY_INTERFACE|g' /home/stack/undercloud.conf"
sudo -H -u stack bash -c "sed -i 's|#discovery_iprange = 192.0.2.100,192.0.2.120|discovery_iprange = $DISCOVERY_IP_START,$DISCOVERY_IP_END|g' /home/stack/undercloud.conf"
sudo -H -u stack bash -c "sed -i 's|#discovery_runbench = false|discovery_runbench = $DISCOVERY_RUNBENCH_BOOL|g' /home/stack/undercloud.conf"
sudo -H -u stack bash -c "sed -i 's|#undercloud_debug = true|undercloud_debug = $UNDERCLOUD_DEBUG_BOOL|g' /home/stack/undercloud.conf"

echo "Launch the following command as user STACK!"
echo "su - stack"
echo "screen"
echo "export HOSTNAME=$FQDN && openstack undercloud install"
echo "CTRL a d"
