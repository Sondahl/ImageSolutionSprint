#!/bin/bash

echo "========================================"
echo "        - Settingup SELinux - "
echo "========================================"
setenforce 0
sed -i 's/SELINUX=\S.*/SELINUX=disabled/g' /etc/selinux/config

echo "========================================"
echo "           - Settinup SSH - "
echo "========================================"
cat <<EOF | tee -a /etc/ssh/ssh_config >/dev/null
        StrictHostKeyChecking no
        CheckHostIP no
EOF

echo "========================================"
echo "          - Disable swap - "
echo "========================================"
swapoff -a
sed -i '/swap/d' /etc/fstab
rm -f /swapfile

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

echo "========================================"
echo "  - Settinup Limits for kubernetes - "
echo "========================================"
rm -f /etc/security/limits.d/20-nproc.conf
cat <<EOF > /etc/security/limits.conf
# Limits for kubernetes
*                soft    nofile         1024000
*                hard    nofile         1024000
*                soft    memlock        unlimited
*                hard    memlock        unlimited
root             soft    nofile         1024000
root             hard    nofile         1024000
root             soft    memlock        unlimited
EOF

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

echo "========================================"
echo "         - Settinup firewall - "
echo "========================================"
systemctl stop firewalld
systemctl disable firewalld

echo "========================================"
echo "            - Update SO - "
echo "========================================"
yum-config-manager -y -q --enable centosplus >/dev/null
sleep 1
yum install -y -q  epel-release
sleep 1
yum -y -q update

echo "========================================"
echo "       - Finnishing script 1 - "
echo "========================================"
