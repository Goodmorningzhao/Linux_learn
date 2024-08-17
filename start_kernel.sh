#!/bin/bash
qemu-system-arm \
    -M vexpress-a9 \
    -m 512M \
    -nographic \
    -kernel project_kernel/arch/arm/boot/zImage \
    -dtb project_kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
    -append "root=/dev/mmcblk0 rw console=ttyAMA0" \
    -sd project_rootfs/vexpress.img

