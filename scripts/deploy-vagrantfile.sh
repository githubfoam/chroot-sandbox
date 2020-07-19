#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

vagrant plugin install vagrant-libvirt #The vagrant-libvirt plugin is required when using KVM on Linux
vagrant plugin install vagrant-mutate #Convert vagrant boxes to work with different providers

vagrant box add "centos/7" --provider=virtualbox
vagrant mutate "centos/7" libvirt
vagrant init --template scripts/Vagrantfile.erb
vagrant up --provider=libvirt vg-chroot-01

#login wiht root
# vagrant ssh -c 'sudo -i' # root@test:~[root@test ~]# 