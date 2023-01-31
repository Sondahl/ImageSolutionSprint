# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-vbguest )
required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure("2") do |config|

  # config.vbguest.auto_update = false
  config.vbguest.installer_hooks[:before_install] = ["setenforce 0","sleep 1","yum-config-manager -y -q --disable base,updates,extras >/dev/null","sleep 1","echo -e '# C7.0.2003\n[C7.0.2003-base]\nname=CentOS-7.0.2003 - Base\nbaseurl=http://archive.kernel.org/centos-vault/7.8.2003/os/x86_64/\ngpgcheck=1\ngpgkey=http://archive.kernel.org/centos-vault/RPM-GPG-KEY-CentOS-7\nenabled=1' > /etc/yum.repos.d/C7.0.2003.repo","sleep 1","yum install -y autoconf kernel-devel-$(uname -r) kernel-headers-$(uname -r) dkms gcc patch libX11 libXt libXext libXmu wget","sleep 1"]

  config.vm.box = "centos/7"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 4
  end

  config.vm.allow_hosts_modification = false
  config.vm.base_mac = "5254004d77d3"

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  #,disabled: false, automount: true

  config.vm.provision "script1", type: "shell", path: "Scripts/script1.sh", privileged: true
  config.vm.provision "shell", reboot: true
  config.vm.provision "script2", type: "shell", path: "Scripts/script2.sh", privileged: true

end
