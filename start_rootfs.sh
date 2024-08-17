#!/bin/bash

sudo rm -rf rootfs
sudo rm -rf tmpfs
sudo rm -f a9rootfs.ext3

sudo mkdir rootfs
sudo cp busybox/_install/*  rootfs/ -raf

sudo mkdir -p rootfs/proc/
sudo mkdir -p rootfs/sys/
sudo mkdir -p rootfs/tmp/
sudo mkdir -p rootfs/root/
sudo mkdir -p rootfs/var/
sudo mkdir -p rootfs/mnt/

sudo cp etc rootfs/ -arf

sudo cp -arf /usr/arm-linux-gnueabi/lib rootfs/

sudo rm rootfs/lib/*.a
sudo arm-linux-gnueabi-strip rootfs/lib/*

sudo mkdir -p rootfs/dev/
sudo mknod rootfs/dev/tty1 c 4 1
sudo mknod rootfs/dev/tty2 c 4 2
sudo mknod rootfs/dev/tty3 c 4 3
sudo mknod rootfs/dev/tty4 c 4 4
sudo mknod rootfs/dev/console c 5 1
sudo mknod rootfs/dev/null c 1 3

sudo dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=32
sudo mkfs.ext3 a9rootfs.ext3

sudo mkdir -p tmpfs
sudo mount -t ext3 a9rootfs.ext3 tmpfs/ -o loop
sudo cp -r rootfs/*  tmpfs/
sudo umount tmpfs

sudo dd if=/dev/zero of=vexpress-ca9-next.img bs=1M count=64
sudo parted vexpress-ca9-next.img --script -- mklabel msdos
sudo parted vexpress-ca9-next.img --script -- mkpart primary fat32 2048s 40960s
sudo parted vexpress-ca9-next.img --script -- mkpart primary ext4 40961s -1


u-boot 支持运行脚本, 我们可以使用脚本来让u-boot自动运行上面的命令行, 不过 u-boot 并不会直接运行纯文本文件, 他需要对脚本文件使用 mkimage 进行打包, 加入头信息, 这是为了安全考虑的.
新建一个文件 boot.cmd , 然后直接拷贝上面的命令行内容到文件
boot.cmd
load mmc 0:0 0x60008000 zImage
load mmc 0:0 0x61000000 vexpress-v2p-ca9.dtb
setenv bootargs "root=/dev/mmcblk0 rw console=ttyAMA0"
bootz 0x60008000 - 0x61000000

mkimage -C none -A arm -T script -d boot.cmd boot.scr

sudo dd if=/dev/zero of=vexpress-ca9-next.img bs=1M count=64
sudo mkfs.fat vexpress-ca9-next.img
sudo mount -o loop vexpress-ca9-next.img  tmpfs/
sudo cp ../project_kernel/arch/arm/boot/zImage  tmpfs/
sudo cp ../project_kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb  tmpfs/
sudo cp boot.scr tmpfs/
sudo umount tmpfs





