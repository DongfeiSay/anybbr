#!/bin/bash
umount /mnt
wget -O /mnt/alpine.tgz http://dl-cdn.alpinelinux.org/alpine/v3.11/releases/x86_64/alpine-minirootfs-3.11.5-x86_64.tar.gz && tar xf /mnt/alpine.tgz -C /mnt
find / \( ! -path /dev/\* -and ! -path /sys/\* -and ! -path /proc/\* -and ! -path /mnt/\* \) -delete 2>/dev/null
/mnt/lib/ld-musl-x86_64.so.1 /mnt/bin/busybox tar xf /mnt/alpine.tgz -C /
echo nameserver\ 1.1.1.1 >/etc/resolv.conf
apk add alpine-base linux-lts openrc openssh dbus grub grub-bios
echo root:cnddy10|chpasswd
sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
cd /etc/runlevels/boot
for boot in $(echo bootmisc hostname hwclock loadkmap modules networking swap sysctl syslog urandom acpid crond sshd dbus);do
	ln -s /etc/init.d/$boot .
done
cd ../sysinit
for sysinit in $(echo devfs dmesg hwdrivers mdev);do
	ln -s /etc/init.d/$sysinit .
done
sleep 1
cd ../shutdown
for shutdown in $(echo killprocs mount-ro savecache);do
	ln -s /etc/init.d/$shutdown .
done
sleep 1
grub-install $(ls /dev/*da)
echo GRUB_CMDLINE_LINUX=modules=ext4\ quiet >>/etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "auto eth0\niface eth0 inet dhcp" >/etc/network/interfaces
rm -rf /mnt/*
echo "安装完成，请重启"
