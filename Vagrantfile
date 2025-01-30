ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|
  config.vm.provision "shell", path: "sceipt.sh"

  NodeCount=2
  (1..NodeCount).each do |i|
    config.vm.define "etcd#{i}" do |etcdnode|
      etcdnode.vm.box = "ubuntu/trusty64"
      etcdnode.vm.hostname = "etcd#{i}.example.com"
      etcdnode.vm.network "private_network", ip: "192.168.56.1#{i}"
      etcdnode.vm.provider :vritualbox do |v|
        v.name = "etcd#{i}"
        v.memory = 1024
        v.cpu = 2
      end
    end
  end
end
