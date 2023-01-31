# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-vbguest )
required_plugins.each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure("2") do |config|

  # config.vbguest.auto_update = false
  config.vbguest.installer_hooks[:before_install] = ["echo -e '[Centos7-2003]\nname=Centos7-2003\nbaseurl=https://buildlogs.centos.org/c7.2003.00.x86_64/\nenabled=1\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7' > /etc/yum.repos.d/c7-2003.repo && yum install -y -q --nogpgcheck autoconf kernel-devel-$(uname -r) kernel-headers-$(uname -r) dkms gcc patch libX11 libXt libXext libXmu wget", "sleep 1"]

  config.vm.box = "centos/7"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 512
    vb.cpus = 4
  end

  config.vm.allow_hosts_modification = false
  config.vm.base_mac = "5254004d77d3"
  # config.vm.boot_timeout = 150

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox" #, automount: true

  config.vm.provision "shell", path: "Scripts/script1.sh", privileged: true
  config.vm.provision "shell", reboot: true
  config.vm.provision "shell", path: "Scripts/script2.sh", privileged: true
  config.vm.provision "shell", reboot: true

end

