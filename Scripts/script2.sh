#!/bin/bash

echo "========================================"
echo "        - Starting script 2 - "
echo "========================================"
mount -a

echo "========================================"
echo "   - Settinup extra repositories - "
echo "========================================"
yum-config-manager -y -q --add-repo https://download.docker.com/linux/centos/docker-ce.repo >/dev/null

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

echo "========================================"
echo " - Installing packages for kubertedes - "
echo "========================================"
yum install -y -q bash-completion bash-completion-extras wget nc nmap telnet traceroute net-tools bind-utils htop jq golang perl ipvsadm ipset git ansible containerd.io kubelet kubeadm kubectl --disableexcludes=kubernetes
yum clean all

echo "========================================"
echo "     - Settinup containerd.io - "
echo "========================================"
systemctl -q start containerd
systemctl -q enable --now containerd
systemctl -q start kubelet
systemctl -q enable --now kubelet

rm -f /etc/containerd/config.toml
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl -q restart containerd
systemctl -q restart kubelet

echo "========================================"
echo "       - Settinup kubernetes - "
echo "========================================"
kubectl completion bash > /etc/bash_completion.d/kubectl.bash
kubeadm completion bash > /etc/bash_completion.d/kubeadm.bash

echo "========================================"
echo "          - Settinup Keys - "
echo "========================================"
rm -f  /root/.ssh/id_rsa*
ssh-keygen -t rsa -N '' -C vagrant -f /root/.ssh/id_rsa <<< y >/dev/null
cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys

rm -f /home/vagrant/.ssh/id_rsa*
sudo -u vagrant ssh-keygen -t rsa -N '' -C vagrant -f /home/vagrant/.ssh/id_rsa <<< y >/dev/null
cat /home/vagrant/.ssh/id_rsa.pub > /home/vagrant/.ssh/authorized_keys
rm -f /vagrant/private_key
cat /home/vagrant/.ssh/id_rsa > /vagrant/private_key

echo "========================================"
echo "          - Cleanup Files - "
echo "========================================"
rm -rf /var/cache/yum/*
rm -f /etc/ssh/*key*
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history
rm -f /etc/sysconfig/network-scripts/ifcfg-e*

echo "========================================"
echo "       - defrag fylesystems - "
echo "========================================"
xfs_fsr -v -d /

echo "========================================"
echo "       - Finnishing script 2 - "
echo "========================================"
