source ~/stackrc
cd /home/stack
wget --no-check-certificate https://raw.githubusercontent.com/jtaleric/csv-to-instack/master/csv-to-instack.py
cat << EOF > /home/stack/instackenv.csv
macaddress,ipmi url,ipmi user, ipmi password, ipmi tool
78:E7:D1:59:99:A0,192.168.1.6,admin,directoriscool,pxe_ipmitool
1C:C1:DE:71:96:D2,192.168.1.7,admin,directoriscool,pxe_ipmitool
D8:D3:85:5E:FF:10,192.168.1.8,admin,directoriscool,pxe_ipmitool
00:22:64:00:AD:5E,192.168.1.9,admin,directoriscool,pxe_ipmitool
1C:C1:DE:76:B7:B0,192.168.1.10,admin,directoriscool,pxe_ipmitool
78:E7:D1:59:A9:D8,192.168.1.11,admin,directoriscool,pxe_ipmitool
1C:C1:DE:EB:FD:40,192.168.1.12,admin,directoriscool,pxe_ipmitool
1C:C1:DE:79:2F:34,192.168.1.13,admin,directoriscool,pxe_ipmitool
1C:C1:DE:79:9F:50,192.168.1.14,admin,directoriscool,pxe_ipmitool
EOF

python csv-to-instack.py --csv=/home/stack/instackenv.csv > /home/stack/instackenv.json && sed -i '1d' /home/stack/instackenv.json
if grep -q '78:E7:D1:59:99:A0' /tmp/instackenv.csv; then
    echo add your own macaddress,ipmi url,ipmi user, ipmi password, ipmi tool
else
    openstack baremetal import --json ~/instackenv.json
    ironic node-list
    openstack baremetal configure boot
    openstack baremetal introspection bulk start
    
fi
