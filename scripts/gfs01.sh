#!/bin/bash -ex

# apt-get update -y
#  apt-get install git -y
#  git clone https://github.com/hocchudong/ghichep-glusterFS.git
#  mv ghichep-glusterFS/scripts/ /root/
#  rm -rf ghichep-glusterFS/
#  cd scripts/
#  chmod +x *.sh 
# 

source config.cfg
source functions.sh

ifaces=/etc/network/interfaces
test -f $ifaces.orig || cp $ifaces $ifaces.orig
rm $ifaces
touch $ifaces
cat << EOF >> $ifaces
#Assign IP for GlusterFS01 node

# LOOPBACK NET
auto lo
iface lo inet loopback

# MGNT + STORAGE NETWORK
auto eth0
iface eth0 inet static
address $GFS01_MGNT_IP
netmask $NETMASK_ADD_MGNT

# EXT NETWORK
auto eth1
iface eth1 inet static
address $GFS01_EXT_IP
netmask $NETMASK_ADD_EXT
gateway $GATEWAY_IP_EXT
dns-nameservers 8.8.8.8
EOF

echocolor "Configuring hostname in GlusterFS01 node"
sleep 3
echo "$HOST_GFS01" > /etc/hostname
hostname -F /etc/hostname

echocolor "Configuring for file /etc/hosts"
sleep 3
iphost=/etc/hosts
test -f $iphost.orig || cp $iphost $iphost.orig
rm $iphost
touch $iphost
cat << EOF >> $iphost
127.0.0.1       localhost $HOST_GFS01
$GFS01_MGNT_IP    $HOST_GFS01
$GFS02_MGNT_IP    $HOST_GFS02
EOF

sleep 5
echocolor "Install GLUSTERFS01"
apt-get -y update
apt-get -y install glusterfs-server

echocolor "Create folder"
sleep 3
mkdir -p /glusterfs/replica

#sleep 5
init 6
#
