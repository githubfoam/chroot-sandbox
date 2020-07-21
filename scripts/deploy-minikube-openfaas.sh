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
