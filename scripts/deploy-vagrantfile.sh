#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

vagrant plugin install vagrant-libvirt #The vagrant-libvirt plugin is required when using KVM on Linux
vagrant plugin install vagrant-mutate #Convert vagrant boxes to work with different providers

# vagrant box add "centos/7" --provider=libvirt

# vagrant init --template templates/Vagrantfile.chroot.erb

# vagrant up --provider=libvirt vg-chroot-01

