# chroot-sandbox
chroot
~~~
sudo apt install debootstrap schroot -y

sudo mkdir /etc/schroot

$ cat /etc/schroot/schroot.conf
[disco]
description=Ubuntu Disco
location=/var/chroot
priority=3
users=vagrant
groups=sbuild
root-groups=root



sudo debootstrap --variant=buildd --arch amd64 disco /var/chroot/ http://ftp.ntua.gr/ubuntu/

$ mount -l | grep chroot
proc on /var/chroot/proc type proc (rw,nosuid,nodev,noexec,relatime)

$ sudo chroot /var/chroot/
root@control01:/#

~~~
~~~
https://help.ubuntu.com/community/BasicChroot
~~~
