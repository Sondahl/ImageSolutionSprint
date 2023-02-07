#!/bin/bash

echo "========================================"
echo "        - Settingup SELinux - "
echo "========================================"
setenforce 0
sed -i 's/SELINUX=\S.*/SELINUX=disabled/g' /etc/selinux/config

echo "========================================"
echo "        - Starting script 1 - "
echo "========================================"
mount -a

echo "========================================"
echo "           - Settinup SSH - "
echo "========================================"
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
cat <<EOF | tee -a /etc/ssh/ssh_config >/dev/null
        StrictHostKeyChecking no

Host *.local
        CheckHostIP no
EOF

echo "========================================"
echo "          - Disable swap - "
echo "========================================"
swapoff -a
sed -i '/swap/d' /etc/fstab
# sed -i 's/(.+ swap .+)/d/' /etc/fstab
# rm -f /swapfile

echo "========================================"
echo "    - Settinup VBguest Network - "
echo "========================================"
mkdir -p /etc/vbox/
cat <<EOF > /etc/vbox/networks.conf
* 0.0.0.0/0 ::/0
EOF

echo "========================================"
echo "      - Settinup VBguest module - "
echo "========================================"
cat <<EOF > /etc/modules-load.d/01-vbox-modules.conf
vboxguest
vboxsf
vboxvideo
EOF

echo "========================================"
echo " - Settinup modules for kubernetes - "
echo "========================================"
cat <<EOF > /etc/modules-load.d/02-k8s-modules.conf
br_netfilter
overlay
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
EOF
modprobe br_netfilter
modprobe overlay
modprobe ip_vs
modprobe ip_vs_rr       
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4

echo "========================================"
echo " - Settinup sysctl for kernel mesages - "
echo "========================================"
cat <<EOF > /etc/sysctl.d/01-printk.conf
kernel.printk = 2 4 1 7
EOF

echo "========================================"
echo "  - Settinup sysctl for kubernetes - "
echo "========================================"
cat <<EOF > /etc/sysctl.d/02-k8s-sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -q --system

echo "========================================"
echo "     - Settinup suspend modes - "
echo "========================================"
cat <<EOF > /etc/systemd/logind.conf
HandleLidSwitch=ignore 
HandleLidSwitchDocked=ignore
EOF
systemctl -q mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null

echo "========================================"
echo "        - Settinup timezone - "
echo "========================================"
timedatectl set-timezone America/Sao_Paulo
cp -f /vagrant/chrony.conf /etc/chrony.conf
systemctl restart chronyd

# echo "========================================"
# echo " - Settinup firewall - "
# echo "========================================"
# systemctl -q enable --now firewalld
# systemctl -q start firewalld
# firewall-cmd -q --set-default-zone=trusted
# firewall-cmd -q --permanent --zone=trusted --add-service=dhcp
# firewall-cmd -q --permanent --zone=trusted --add-service=dhcpv6-client
# firewall-cmd -q --permanent --zone=trusted --add-service=dns
# firewall-cmd -q --permanent --zone=trusted --add-service=etcd-client
# firewall-cmd -q --permanent --zone=trusted --add-service=etcd-server
# firewall-cmd -q --permanent --zone=trusted --add-service=git
# firewall-cmd -q --permanent --zone=trusted --add-service=http
# firewall-cmd -q --permanent --zone=trusted --add-service=https
# firewall-cmd -q --permanent --zone=trusted --add-service=samba-client
# firewall-cmd -q --permanent --zone=trusted --add-service=ssh
# firewall-cmd -q --permanent --zone=trusted --add-service=snmp
# firewall-cmd -q --permanent --zone=trusted --add-service=ntp
# firewall-cmd -q --permanent --zone=trusted --add-port=2379-2380/tcp
# firewall-cmd -q --permanent --zone=trusted --add-port=8285/udp
# firewall-cmd -q --permanent --zone=trusted --add-port=6443/tcp
# firewall-cmd -q --permanent --zone=trusted --add-port=6783/tcp
# firewall-cmd -q --permanent --zone=trusted --add-port=6783/udp
# firewall-cmd -q --permanent --zone=trusted --add-port=6784/udp
# firewall-cmd -q --permanent --zone=trusted --add-port=8090/tcp
# firewall-cmd -q --permanent --zone=trusted --add-port=8091/tcp 
# firewall-cmd -q --permanent --zone=trusted --add-port=8472/udp
# firewall-cmd -q --permanent --zone=trusted --add-port=10250/tcp
# firewall-cmd -q --permanent --zone=trusted --add-port=10251/tcp
# firewall-cmd -q --permanent --zone=trusted --add-port=10252/tcp
# firewall-cmd -q --permanent --zone=trusted --add-port=10255/tcp
# firewall-cmd -q --permanent --zone=trusted --add-port=30000-32767/tcp
# firewall-cmd -q --reload

echo "========================================"
echo "            - Update SO - "
echo "========================================"
# yum-config-manager -q -y --disable C7.0.2003-base >/dev/null
# sleep 1
yum-config-manager -y -q --enable centosplus >/dev/null
sleep 1
yum groups install -y "Minimal Install"
yum install -y epel-release
sleep 1
yum -y update

echo "========================================"
echo "       - Finnishing script 1 - "
echo "========================================"
