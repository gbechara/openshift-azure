#!/bin/bash

rhn_username=$1
rhn_pass=$2
rhn_pool=$3


subscription-manager register --username=${rhn_username} --password=${rhn_pass} --force
subscription-manager attach --pool=${rhn_pool}

subscription-manager repos --disable="*"
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.4-rpms"

sed -i -e 's/sslverify=1/sslverify=0/' /etc/yum.repos.d/rh-cloud.repo
sed -i -e 's/sslverify=1/sslverify=0/' /etc/yum.repos.d/rhui-load-balancers

yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion docker
# yum -y update

sed -i -e "s#^OPTIONS='--selinux-enabled'#OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0/16'#" /etc/sysconfig/docker

cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdc
VG=docker-vg
EOF

docker-storage-setup
systemctl enable docker

systemctl start docker

mkdir /srv/gitlab
mkdir /srv/gitlab/data
mkdir /srv/gitlab/config
mkdir /srv/gitlab/logs

docker run --detach \
--hostname gitlab.example.com \
--publish 443:443 --publish 80:80 --publish 8022:22 \
--name gitlab \
--restart always \
--volume /srv/gitlab/config:/etc/gitlab:Z \
--volume /srv/gitlab/logs:/var/log/gitlab:Z \
--volume /srv/gitlab/data:/var/opt/gitlab:Z \
gitlab/gitlab-ce:latest


mkdir /srv/nexus-data

docker run --detach \
--hostname ose-utils.example.com \
--publish 8081:8081 \
--name nexus \
--restart always \
--volume /srv/nexus-data:/sonatype-work:Z \
--user root \
sonatype/nexus

yum -y install nfs-utils rpcbind
mkdir /opt/nfs
mkdir /opt/nfs/pv0001
mkdir /opt/nfs/pv0002
mkdir /opt/nfs/pv0003
mkdir /opt/nfs/pv0004
mkdir /opt/nfs/pv0005
mkdir /opt/nfs/pv0006
mkdir /opt/nfs/pv0007
mkdir /opt/nfs/pv0008
mkdir /opt/nfs/pv0009
mkdir /opt/nfs/pv0010
mkdir /opt/nfs/pv0011
mkdir /opt/nfs/pv0012
mkdir /opt/nfs/pv0013
mkdir /opt/nfs/pv0014
mkdir /opt/nfs/pv0015
mkdir /opt/nfs/pv0016
mkdir /opt/nfs/pv0017
mkdir /opt/nfs/pv0018
mkdir /opt/nfs/pv0019
mkdir /opt/nfs/pv0020


chown -R nfsnobody:nfsnobody /opt/nfs
chmod -R 0775 /opt/nfs


cat <<EOF > /etc/exports
/opt/nfs node01(rw,root_squash,no_wdelay)
/opt/nfs node02(rw,root_squash,no_wdelay)
/opt/nfs node03(rw,root_squash,no_wdelay)
EOF

chmod 644 /etc/exports
systemctl start rpcbind
systemctl start nfs-server
systemctl enable rpcbind
systemctl enable nfs-server

systemctl stop firewalld
systemctl disable firewalld
