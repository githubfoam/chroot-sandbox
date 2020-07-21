#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================configure vagrant shared folder============================================================="
echo "install aliases and augment path"

# for a in `find home -name "*" -type f` ; do
#   rm -f $VAGRANT_USER_HOME/`basename $a`
#   ln -rs $a /home/vagrant
# done

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

echo "=============================Install kubectl============================================================="
curl -LsO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

echo "=============================Install minikube============================================================="
# https://github.com/kubernetes/minikube

export VAGRANT_USER_HOME=/home/vagrant
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$VAGRANT_USER_HOME
export CHANGE_MINIKUBE_NONE_USER=true
export KUBECONFIG=$VAGRANT_USER_HOME/.kube/config
mkdir -p $VAGRANT_USER_HOME/.kube
mkdir -p $VAGRANT_USER_HOME/.minikube
touch $KUBECONFIG



curl -Lso minikube https://storage.googleapis.com/minikube/releases/v0.31.0/minikube-linux-amd64 && chmod +x minikube && cp minikube /usr/local/bin/ && rm minikube

# minikube needs socat for port forwarding when using the --vm-driver=none
yum install -y socat

minikube start --vm-driver=none --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf

# waits until kubectl can access the api server that minikube has created
for i in {1..150}; do # timeout for 5 minutes
   kubectl get po &> /dev/null
   if [ $? -ne 1 ]; then
      break
  fi
  sleep 2
done

chown -R vagrant.vagrant $VAGRANT_USER_HOME/.kube
chown -R vagrant.vagrant $VAGRANT_USER_HOME/.minikube

echo "=============================Install helm============================================================="
# https://github.com/helm/helm

HELM_ARCHIVE=helm-v2.16.9-linux-arm64.tar.gz
HELM_DIR=linux-amd64
HELM_BIN=$HELM_DIR/helm

curl -LsO https://storage.googleapis.com/kubernetes-helm/$HELM_ARCHIVE && tar -zxvf $HELM_ARCHIVE && chmod +x $HELM_BIN && cp $HELM_BIN /usr/local/bin
rm $HELM_ARCHIVE
rm -rf $HELM_DIR

# setup tiller account
kubectl -n kube-system create sa tiller && kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# initialize tiller
helm init --wait --skip-refresh --upgrade --service-account tiller


echo "=============================Install OpenFaas============================================================="
# https://github.com/openfaas/faas
# https://github.com/openfaas/faas-cli

export OPENFAAS_GW=$(minikube ip):31112
export OPENFAAS_GW_PW=admin
export OPENFAAS_REGISTRY=localhost:5000

# apply openfaas namespaces
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

# add openfaas repo
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update

# create openfaas secret...
kubectl -n openfaas create secret generic basic-auth --from-literal=basic-auth-user=admin --from-literal=basic-auth-password="$OPENFAAS_GW_PW"

# upgrade openfaas...
helm upgrade openfaas --install openfaas/openfaas --namespace openfaas --set functionNamespace=openfaas-fn --set basic_auth=true


faas_cli_version=0.12.8
echo "fetch and install faas-cli (version $faas_cli_version)"
wget -q -O /usr/local/bin/faas-cli https://github.com/openfaas/faas-cli/releases/download/${faas_cli_version}/faas-cli && chmod +x /usr/local/bin/faas-cli


# fix faas_nats_address (cf. https://github.com/openfaas/faas-netes/issues/351)
kubectl -n openfaas set env deployment/gateway faas_nats_address=nats.openfaas.svc.cluster.local.
kubectl -n openfaas set env deployment/queue-worker faas_nats_address=nats.openfaas.svc.cluster.local.

# verify that openfaas has started
# kubectl --namespace=openfaas get deployments -l "release=openfaas, app=openfaas"
