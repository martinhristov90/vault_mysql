# Vagrantfile API/syntax version.
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # our mysql box
    config.vm.define vm_name1="mysql" do |node|
        node.vm.box = "martinhristov90/ubuntu_mysql"
        node.vm.hostname = vm_name1
        node.vm.network "private_network", ip: "192.168.0.11"
        node.vm.provision "shell", path: "./configs/scripts/mysqlSetup.sh", privileged: true
        #node.vm.synced_folder "db/", "/usr/local/db/", create: true
    end
    # end of mysql
    
    # begin of Vault Server
    config.vm.define vm_name="vaultServer" do |node|
        node.vm.box = "martinhristov90/vault"
        node.vm.hostname = vm_name
        node.vm.network "private_network", ip: "192.168.0.22"
        node.vm.network "forwarded_port", guest: 8200, host: 8200
        node.vm.network "forwarded_port", guest: 8201, host: 8201
        node.vm.provision "shell", path: "./configs/scripts/vaultSetup.sh", privileged: false
    end
    # end of vault
    
end