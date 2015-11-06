source ~/stackrc
openstack baremetal import --json ~/instackenv.json
ironic node-list
openstack baremetal configure boot
openstack baremetal introspection bulk start

