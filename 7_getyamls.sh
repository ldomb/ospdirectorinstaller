cd /home/stack/templates/
wget --no-check-certificate https://raw.githubusercontent.com/ldomb/ospdirectorinstaller/master/yamlconfigs/ceph-environment.yaml
wget --no-check-certificate https://raw.githubusercontent.com/ldomb/ospdirectorinstaller/master/yamlconfigs/firstboot-environment.yaml
wget --no-check-certificate https://github.com/ldomb/ospdirectorinstaller/blob/master/yamlconfigs/limits.yaml
cd /home/stack/templates/firstboot/
wget --no-check-certificate https://raw.githubusercontent.com/ldomb/ospdirectorinstaller/master/yamlconfigs/ceph_wipe.yaml
wget --no-check-certificate https://github.com/ldomb/ospdirectorinstaller/blob/master/yamlconfigs/firstboot-config.yaml
wget --no-check-certificate https://github.com/ldomb/ospdirectorinstaller/blob/master/yamlconfigs/fix_rabbit.yaml
