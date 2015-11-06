sudo sed -i 's/#\(max_concurrent_builds\).*/\1=4/' /etc/nova/nova.conf
sudo sed -i 's/#\(rpc_thread_pool_size\).*/\1=8/' /etc/ironic/ironic.conf
for i in $(sudo systemctl | awk '/ironic|nova/{print$1}'); do sudo systemctl restart $i; done
