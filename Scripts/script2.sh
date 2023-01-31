#!/bin/bash

# /sbin/rcvboxadd quicksetup all
# systemctl restart vboxadd.service
# systemctl restart vboxadd-service.service
mount /vagrant

yum install -y -q --nogpgcheck-q epel-release  
yum install -y -q --nogpgcheck-q https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm 
yum-config-manager -q -y --enable centosplus >/dev/null 2>&1
yum-config-manager -q -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo 

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# sudo yum groups install -y -q --nogpgcheck "Minimal Install"
yum install -y -q --nogpgcheck --disableexcludes=kubernetes glibc-headers glibc-devel nc nmap telnet traceroute net-tools bind-utils htop lvm2 device-mapper-persistent-data samba-client jq golang perl arptables ipvsadm containerd.io kubelet kubeadm kubectl
yum remove -y -q open-vm-tools
yum clean all

systemctl -q start containerd
systemctl -q enable --now containerd
systemctl -q start kubelet
systemctl -q enable --now kubelet


rm -f /etc/containerd/config.toml
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl -q stop containerd
systemctl -q stop kubelet

wget -nv "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert" -P /tmp >/dev/null 2>&1
install -o root -g root -m 0755 /tmp/kubectl-convert /usr/local/bin/kubectl-convert
rm -f /tmp/kubectl-convert

kubectl completion bash > /etc/bash_completion.d/kubectl.bash
kubeadm completion bash > /etc/bash_completion.d/kubeadm.bash

# echo "$(sudo ssh-keygen -y -f /vagrant/insecure_private_key) vagrant" > /home/vagrant/.ssh/authorized_keys
# sudo ssh-keygen -y -f /vagrant/insecure_private_key
ssh-keygen -t rsa -N '' -C vagrant -f /root/.ssh/id_rsa <<< y >/dev/null 2>&1
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

sudo -u vagrant ssh-keygen -t rsa -N '' -C vagrant -f /home/vagrant/.ssh/id_rsa <<< y >/dev/null 2>&1
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
cp -f /home/vagrant/.ssh/id_rsa /vagrant/private_key

rm -f /etc/ssh/*key*
