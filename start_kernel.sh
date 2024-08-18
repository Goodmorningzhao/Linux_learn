#!/bin/bash
sudo qemu-system-arm \
        -M vexpress-a9 \
        -m 512M \
        -nographic \
        -kernel project_kernel/arch/arm/boot/zImage \
        -dtb project_kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
        -append "root=/dev/mmcblk0 rw console=ttyAMA0" \
        -sd project_rootfs/vexpress-ca9.img

# 该脚本主要是拷贝kernel下的image和dtb到当前images目录, 然后执行qemu仿真, 这里可以传一个参数only代表只有串口终端没有画面, 默认有画面可以通过vnc链接, 但是电脑比较渣没有开启图形界面。这里需要给脚本执行权限sudo chmod +x kernel-qemu.
# #!/bin/sh
# IMAGE_DIR="${0%/*}/"
# BUILD_ROOTDIR=`realpath ../`
# echo $BUILD_ROOTDIR
# cp $BUILD_ROOTDIR/build/linux-custom/arch/arm/boot/zImage .
# cp $BUILD_ROOTDIR/build/linux-custom/arch/arm/boot/uImage .
# cp $BUILD_ROOTDIR/build/linux-custom/arch/arm/boot/dts/vexpress-v2p-ca9.dtb .

# if [ "${1}" = "only" ]; then
#     EXTRA_ARGS='-nographic'
# else
#     EXTRA_ARGS='-serial stdio'
# fi

# export PATH="/home/vencol/code/vexpressa9/rootfs/host/bin:${PATH}"
# exec   qemu-system-arm -M vexpress-a9 -smp 1 -m 256 -kernel ${IMAGE_R}/zImage -dtb ${IMAGE_DIR}/vexpress-v2p-ca9.dtb -drive file=${IMAGE_DIR}/rootfs.ext2,if=sd,format=raw -append "console=ttyAMA0,115200 rootwait root=/dev/mmcblk0"  -net nic,model=lan9118 -net user  ${EXTRA_ARGS}