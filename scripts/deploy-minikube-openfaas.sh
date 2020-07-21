#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================configure vagrant shared folder============================================================="
echo "install aliases and augment path"

for a in `find home -name "*" -type f` ; do
  rm -f $VAGRANT_USER_HOME/`basename $a`
  ln -rs $a /home/vagrant
done
echo "export PATH=$PATH:/vagrant/scripts/bin" >> $VAGRANT_USER_HOME/.bashrc


echo "=============================Install docker============================================================="
# https://docs.docker.com/engine/install/centos/

# Uninstall old versions
yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# Install using the repository Set up the repository
yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


# Install Docker Engine
yum install -y docker-ce docker-ce-cli containerd.io

# Start Docker
systemctl start docker 
systemctl status docker

# add user to docker group
usermod -aG docker vagrant

# update the locale LANG
update-locale LANG=en_US.UTF-8


echo "=============================Install minikube============================================================="
export VAGRANT_USER_HOME=/home/vagrant
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$VAGRANT_USER_HOME
export CHANGE_MINIKUBE_NONE_USER=true
export KUBECONFIG=$VAGRANT_USER_HOME/.kube/config
mkdir -p $VAGRANT_USER_HOME/.kube
mkdir -p $VAGRANT_USER_HOME/.minikube
touch $KUBECONFIG
