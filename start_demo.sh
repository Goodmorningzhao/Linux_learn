#!/bin/bash


QEMU_TOOL=qemu-system-arm

########BOARD_OPTIONS="-m 4096M -cpu cortex-a53 -smp 2 -M virt"
BOARD_OPTIONS="-m 512M -M vexpress-a9"

# 不支持USB
#USB_DEV="-usb -usbdevice keyboard -machine usb=on"

DISK_IMG=mmcblock.img

KERNEL_ELF=/home/user/work/qemu/imx8_qemu/uboot-imx/u-boot-a9

NET_OPTIONS="-net nic -net tap,ifname=tap0,script=NET_IFUP.sh,downscript=NET_IFDOWN.sh"

#/Dev/mmcblk0
HARD_DISK1="-sd ${DISK_IMG}"s

#SEMIHOST配置
# uboot控制台中的'smhload kernel 0x40008000'
#SEMIHOST_OPT=" -d unimp -semihosting-config enable=on,target=native "
SEMIHOST_OPT=" -semihosting-config enable=on,target=native "

#如果启用-serial，并且不应该启用-nographic
#SERIAL="-serial stdio"
SERIAL="-nographic"

sudo ${QEMU_TOOL} ${BOARD_OPTIONS}\
${NET_OPTIONS} \
${USB_DEV} \
-kernel ${KERNEL_ELF} \
${HARD_DISK1} \
${SEMIHOST_OPT} \
${SERIAL}