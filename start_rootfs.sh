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
******************************************************************
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

sudo mkfs.fat vexpress-ca9-next.img
sudo mount -o loop vexpress-ca9-next.img  tmpfs/
sudo cp ../project_kernel/arch/arm/boot/zImage  tmpfs/
sudo cp ../project_kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb  tmpfs/
sudo cp boot.scr tmpfs/
sudo umount tmpfs
******************************************************************
#创建SD镜像
$ sudo dd if=/dev/zero of=vexpress-ca9-next.img bs=1M count=64
[sudo] password for xpeng: 
64+0 records in
64+0 records out
67108864 bytes (67 MB, 64 MiB) copied, 0.146629 s, 458 MB/s
#创建放置内核文件的分区，大小为16M
$ sudo sgdisk -n 0:0:+16M -c 0:kernel vexpress-ca9-next.img 
Creating new GPT entries in memory.
Setting name!
partNum is 0
Warning: The kernel is still using the old partition table.
The new table will be used at the next reboot or after you
run partprobe(8) or kpartx(8)
The operation has completed successfully. 
#使用剩余空间创建根文件系统分区
$ sudo sgdisk -n 0:0:0 -c 0:rootfs vexpress-ca9-next.img 
Setting name!
partNum is 1
Warning: The kernel is still using the old partition table.
The new table will be used at the next reboot or after you
run partprobe(8) or kpartx(8)
The operation has completed successfully.
#显示分区信息
$ sudo sgdisk -p vexpress-ca9-next.img 
Disk vexpress-ca9-next.img: 131072 sectors, 64.0 MiB
Sector size (logical): 512 bytes
Disk identifier (GUID): 2034661E-C6FE-48EF-A01B-33D02DDB14F6
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 33
First usable sector is 34, last usable sector is 131038
Partitions will be aligned on 2048-sector boundaries
Total free space is 2014 sectors (1007.0 KiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048           34815   16.0 MiB    8300  kernel
   2           34816          131038   47.0 MiB    8300  rootfs
#显示一个空的loop文件
$ sudo losetup -f
/dev/loop13
#将SD镜像挂载到空的loop设备上,如果报错一般是因为losetup -f 显示的设备不可用
$ sudo losetup /dev/loop13 vexpress-ca9-next.img
#将指定设备的分区变化通知操作系统
sudo partprobe /dev/loop13
#可以使用以下命令代替 ？？？？
$ sudo losetup -fP --show vexpress-ca9-next.img 
/dev/loop14

$ ls /dev/loop13*
/dev/loop13  /dev/loop13p1  /dev/loop13p2
#格式化分区，为了和u-boot 相关设置兼容，建议文件格式为ext3
$ sudo mkfs.ext3 /dev/loop13p1
mke2fs 1.45.5 (07-Jan-2020)
Discarding device blocks: done                            
Creating filesystem with 4096 4k blocks and 4096 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done

$ sudo mkfs.ext3 /dev/loop13p2
mke2fs 1.45.5 (07-Jan-2020)
Discarding device blocks: done                            
Creating filesystem with 12027 4k blocks and 12032 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
#挂载
$ mkdir tmpfs/p1
$ mkdir tmpfs/p2

$ sudo mount -t ext3 /dev/loop13p1 tmpfs/p1
$ sudo mount -t ext3 /dev/loop13p2 tmpfs/p2

$ sudo cp ../project_kernel/arch/arm/boot/uImage  tmpfs/p1/
$ sudo cp ../project_kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb  tmpfs/p2/
$ sudo cp -r rootfs/* tmpfs/p2/
#卸载
$ sudo umount tmpfs/p1 tmpfs/p2
$ sudo losetup -d /dev/loop13


#define CONFIG_BOOTCOMMAND "load mmc 0:1 0x60003000 uImage;" \
"load mmc 0:2 0x60800000 vexpress-v2p-ca9.dtb;" \
"setenv bootargs 'root=/dev/mmcblk0p2 rw rootfstyp3=ext3 rootwait earlycon console=ttyAMA0 init=/linuxrc ignore_loglevel' \
"bootm 0x60003000 - 0x60800000;"





