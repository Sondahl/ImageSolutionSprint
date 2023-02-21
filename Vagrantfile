# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-vbguest )
required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure("2") do |config|

  config.vm.box = "sondahl/centos7-2009"
  config.vm.hostname = "ImgSolutionSprint"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "ImgSolutionSprint"
    vb.memory = 2048
    vb.cpus = 4
  end

  config.vm.allow_hosts_modification = false
  config.vm.base_mac = "5254004d77d3"

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provision "script1", type: "shell", path: "Scripts/script1.sh", privileged: true
  config.vm.provision "shell", reboot: true
  config.vm.provision "script2", type: "shell", path: "Scripts/script2.sh", privileged: true

end
