#!/bin/sh

# Linux
KERNEL="${HOME}/./vmlinuz-3.10.0-957.el7.x86_64"
INITRD="${HOME}/./initramfs-3.10.0-957.el7.x86_64.img"
CMDLINE="earlyprintk=serial quiet console=ttyS0 acpi=off root=/dev/mapper/centos-root rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rw"

MEM="-m 4G"
SMP="-c 2"
NET="-s 2:0,virtio-net"
IMG_HDD="-s 4,virtio-blk,${HOME}/./hdd.img"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
UUID="-U deadbeef-dead-dead-dead-deaddeafbeef"
xhyve $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE" >/dev/null 2>&1 &
