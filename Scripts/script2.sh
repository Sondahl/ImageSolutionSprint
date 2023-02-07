#!/bin/bash

echo "========================================"
echo "        - Starting script 2 - "
echo "========================================"

echo "========================================"
echo "     - Buildind VBguest modules - "
echo "========================================"
/sbin/rcvboxadd quicksetup all
mount -a

echo "========================================"
echo "   - Settinup extra repositories - "
echo "========================================"
# yum install -y -q https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm >/dev/null
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
# yum install -y glibc-headers glibc-devel nc nmap telnet traceroute net-tools bind-utils htop lvm2 device-mapper-persistent-data samba-client jq golang perl arptables ipvsadm containerd.io kubelet kubeadm kubectl --disableexcludes=kubernetes
yum install -y bash-completion-extras wget nc nmap telnet traceroute net-tools bind-utils htop jq golang perl ipvsadm ipset git ansible containerd.io kubelet kubeadm kubectl --disableexcludes=kubernetes
yum remove -y open-vm-tools
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
# wget -nv "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert" -P /tmp >/dev/null
# install -o root -g root -m 0755 /tmp/kubectl-convert /usr/local/bin/kubectl-convert
# rm -f /tmp/kubectl-convert

kubectl completion bash > /etc/bash_completion.d/kubectl.bash
kubeadm completion bash > /etc/bash_completion.d/kubeadm.bash

echo "========================================"
echo "       - defrag fylesystems - "
echo "========================================"
xfs_fsr

echo "========================================"
echo "         - Settinup Keys - "
echo "========================================"
# echo "$(ssh-keygen -y -f /vagrant/insecure_private_key) vagrant" > /home/vagrant/.ssh/authorized_keys

rm -f  /root/.ssh/id_rsa*
ssh-keygen -t rsa -N '' -C vagrant -f /root/.ssh/id_rsa <<< y >/dev/null
cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys

rm -f /home/vagrant/.ssh/id_rsa*
sudo -u vagrant ssh-keygen -t rsa -N '' -C vagrant -f /home/vagrant/.ssh/id_rsa <<< y >/dev/null
cat /home/vagrant/.ssh/id_rsa.pub > /home/vagrant/.ssh/authorized_keys
rm -f /vagrant/private_key
cat /home/vagrant/.ssh/id_rsa > /vagrant/private_key

rm -f /etc/ssh/*key*
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# sleep 5 
# cp -f /vagrant/monitor.service /etc/systemd/system/
# systemctl daemon-reload
# systemctl start monitor.service
# systemctl status monitor.service

echo "========================================"
echo " - Finnishing script 2 - "
echo "========================================"
