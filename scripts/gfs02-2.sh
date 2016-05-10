#!/bin/bash -ex

source config.cfg
source functions.sh

sleep 5
echocolor "Install GLUSTERFS02"
apt-get -y update
apt-get -y install glusterfs-server

echocolor "Create folder"
sleep 3
mkdir -p /glusterfs/replica

echocolor "Search the server"
gluster peer probe $HOST_GFS01
sleep 3

echocolor "show status"
sleep 3
gluster peer status 

echocolor "Create a volume"
gluster volume create vol_replica replica 2 transport tcp \
$HOST_GFS01:/glusterfs/replica \
$HOST_GFS02:/glusterfs/replica force

echocolor "Start the volume"
sleep 3
gluster volume start vol_replica


echocolor "Show info"
sleep 3
gluster volume info 

#sleep 5
#
