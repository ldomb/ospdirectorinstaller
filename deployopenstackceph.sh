source ~/stackrc
cd ~
openstack overcloud deploy --templates \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
-e /home/stack/templates/environments/storage-environment.yaml \
-e /home/stack/templates/network-environment.yaml \
-e /home/stack/templates/limits.yaml \
-e /home/stack/templates/infra-environment.yaml \
-e /home/stack/templates/firstboot-environment.yaml \
--control-flavor control \
--compute-flavor compute \
--ceph-storage-flavor ceph-storage \
--control-scale 3 \
--compute-scale 3 \
--ceph-storage-scale 3 \
--ntp-server time.nist.gov \
--neutron-tunnel-types vxlan \
--neutron-network-type vxlan \
