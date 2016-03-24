# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.forward_agent = true

  config.vm.define 'wtracker' do |wtracker|
    wtracker.vm.box = 'ubuntu/trusty64'

    wtracker.vm.network 'forwarded_port', guest: 3000, host: 3000
    # wtracker.vm.network 'private_network', ip: '192.168.77.77'

    wtracker.vm.synced_folder '.', '/home/vagrant/wtracker'
    config.vm.provision 'shell', path: 'vagrantprovision.sh'
  end


  config.vm.provider 'virtualbox' do |v|
    v.memory = 4096
  end
end
