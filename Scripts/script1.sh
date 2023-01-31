#!/bin/bash

mkdir -p /etc/vbox/
cat <<EOF > /etc/vbox/networks.conf
* 0.0.0.0/0 ::/0
EOF
cat <<EOF > /etc/modules-load.d/00-vbox-modules.conf
vboxguest
vboxsf
vboxvideo
EOF
modprobe vboxguest
modprobe vboxsf
modprobe vboxvideo
# systemctl restart vboxadd.service
# systemctl restart vboxadd-service.service
mount /vagrant

setenforce 0
sed -i 's/SELINUX=\S.*/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
swapoff -a
sed -i -r 's/(.+ swap .+)/#\1/' /etc/fstab
rm -f /swapfile

cat <<EOF > /etc/modules-load.d/99-k8s-modules.conf
br_netfilter
overlay
EOF
modprobe br_netfilter
modprobe overlay

cat <<EOF > /etc/sysctl.d/99-k8s-sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -q --system

systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

timedatectl set-timezone America/Sao_Paulo
cp -f /vagrant/chrony.conf /etc/chrony.conf
systemctl restart chronyd

systemctl enable --now firewalld
systemctl start firewalld
firewall-cmd -q --set-default-zone=trusted
firewall-cmd -q --permanent --zone=trusted --add-service=dhcp
firewall-cmd -q --permanent --zone=trusted --add-service=dhcpv6-client
firewall-cmd -q --permanent --zone=trusted --add-service=dns
firewall-cmd -q --permanent --zone=trusted --add-service=etcd-client
firewall-cmd -q --permanent --zone=trusted --add-service=etcd-server
firewall-cmd -q --permanent --zone=trusted --add-service=git
firewall-cmd -q --permanent --zone=trusted --add-service=http
firewall-cmd -q --permanent --zone=trusted --add-service=https
firewall-cmd -q --permanent --zone=trusted --add-service=samba-client
firewall-cmd -q --permanent --zone=trusted --add-service=ssh
firewall-cmd -q --permanent --zone=trusted --add-service=snmp
firewall-cmd -q --permanent --zone=trusted --add-service=ntp
firewall-cmd -q --permanent --zone=trusted --add-port=2379-2380/tcp
firewall-cmd -q --permanent --zone=trusted --add-port=8285/udp
firewall-cmd -q --permanent --zone=trusted --add-port=6443/tcp
firewall-cmd -q --permanent --zone=trusted --add-port=6783/tcp
firewall-cmd -q --permanent --zone=trusted --add-port=6783/udp
firewall-cmd -q --permanent --zone=trusted --add-port=6784/udp
firewall-cmd -q --permanent --zone=trusted --add-port=8090/tcp
firewall-cmd -q --permanent --zone=trusted --add-port=8091/tcp 
firewall-cmd -q --permanent --zone=trusted --add-port=8472/udp
firewall-cmd -q --permanent --zone=trusted --add-port=10250/tcp
firewall-cmd -q --permanent --zone=trusted --add-port=10251/tcp
firewall-cmd -q --permanent --zone=trusted --add-port=10252/tcp
firewall-cmd -q --permanent --zone=trusted --add-port=10255/tcp
firewall-cmd -q --permanent --zone=trusted --add-port=30000-32767/tcp
firewall-cmd -q --reload

yum-config-manager -q -y --disable Centos7-2003 >/dev/null 2>&1
yum -y -q --nogpgcheck update
sleep 1