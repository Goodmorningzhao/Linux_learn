# Linux_learn
*******************************************************************
1. u-boot
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm distclean
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./../project_uboot vexpress_ca9x4_defconfig //配置
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./../project_uboot  //编译
1.1 直接启动u-boot 
qemu-system-arm -M vexpress-a9 \
     -kernel u-boot \
     -nographic \
     -m 512M
*******************************************************************
2. Kernel

*** 开启Qemu的网络支持功能, 启动u-boot, 设置u-boot的环境变量, u-boot采用tftp的方式将uImage格式的Linux内核下载到内存地址0x60003000处
***为什么是0x60000000起始的地址, 参考文件u-boot的配置文件 include/configs/vexpress_common.h
***如果用Qemu直接启动Kernel, 是通过-append parameter 的方式给kernel传参的
***现在是通过u-boot, 那么需要通过u-boot的环境变量bootargs
***可以设置为如下值 setenv bootargs 'root=/dev/mmcblk0 console=ttyAMA0 console=tty0'
***然后设置u-boot环境变量bootcmd, 如下: setenv bootcmd 'tftp 0x60003000 uImage; bootm 0x60003000'

mkdir project_kernel
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm  O=./project_kernel distclean
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel vexpress_defconfig
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel menuconfig
2.1.1
$ make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel zImage -j2
...
...
...
  AS      arch/arm/boot/compressed/piggy.o
  AS      arch/arm/boot/compressed/hyp-stub.o
  AS      arch/arm/boot/compressed/lib1funcs.o
  AS      arch/arm/boot/compressed/ashldi3.o
  AS      arch/arm/boot/compressed/bswapsdi2.o
  LD      arch/arm/boot/compressed/vmlinux
  OBJCOPY arch/arm/boot/zImage
  Kernel: arch/arm/boot/zImage is ready
make[1]: Leaving directory '/home/xpeng/Documents/Linux_learn/project_kernel'
2.1.2
$ make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel modules -j2
...
...
...
  GEN     Makefile
  CALL    ../scripts/atomic/check-atomics.sh
  CALL    ../scripts/checksyscalls.sh
  Building modules, stage 2.
  MODPOST 0 modules
make[1]: Leaving directory '/home/xpeng/Documents/Linux_learn/project_kernel'
2.1.3
$ make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel dtbs -j2
...
...
...
  DTC     arch/arm/boot/dts/vexpress-v2p-ca5s.dtb
  DTC     arch/arm/boot/dts/vexpress-v2p-ca9.dtb
  DTC     arch/arm/boot/dts/vexpress-v2p-ca15-tc1.dtb
  DTC     arch/arm/boot/dts/vexpress-v2p-ca15_a7.dtb
make[1]: Leaving directory '/home/xpeng/Documents/Linux_learn/project_kernel'
2.1.4
$ make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel LOADADDR=0x60003000 uImage  -j2
...
...
...
  GEN     Makefile
  CALL    ../scripts/atomic/check-atomics.sh
  CALL    ../scripts/checksyscalls.sh
  CHK     include/generated/compile.h
  Kernel: arch/arm/boot/Image is ready
  Kernel: arch/arm/boot/zImage is ready
  UIMAGE  arch/arm/boot/uImage
Image Name:   Linux-5.4.276+
Created:      Wed Aug 14 00:36:54 2024
Image Type:   ARM Linux Kernel Image (uncompressed)
Data Size:    4700616 Bytes = 4590.45 KiB = 4.48 MiB
Load Address: 60003000
Entry Point:  60003000
  Kernel: arch/arm/boot/uImage is ready
make[1]: Leaving directory '/home/xpeng/Documents/Linux_learn/project_kernel'

2.2 直接启动kernel 
该脚本主要是拷贝kernel下的image和dtb到当前images目录, 然后执行qemu仿真, 这里可以传一个参数only代表只有串口终端没有画面, 默认有画面可以通过vnc链接, 但是电脑比较渣没有开启图形界面。这里需要给脚本执行权限sudo chmod +x kernel-qemu.
#!/bin/sh
IMAGE_DIR="${0%/*}/"
BUILD_ROOTDIR=`realpath ../`
echo $BUILD_ROOTDIR
cp $BUILD_ROOTDIR/build/linux-custom/arch/arm/boot/zImage .
cp $BUILD_ROOTDIR/build/linux-custom/arch/arm/boot/uImage .
cp $BUILD_ROOTDIR/build/linux-custom/arch/arm/boot/dts/vexpress-v2p-ca9.dtb .

if [ "${1}" = "only" ]; then
    EXTRA_ARGS='-nographic'
else
    EXTRA_ARGS='-serial stdio'
fi

export PATH="/home/vencol/code/vexpressa9/rootfs/host/bin:${PATH}"
exec   qemu-system-arm -M vexpress-a9 -smp 1 -m 256 -kernel ${IMAGE_R}/zImage -dtb ${IMAGE_DIR}/vexpress-v2p-ca9.dtb -drive file=${IMAGE_DIR}/rootfs.ext2,if=sd,format=raw -append "console=ttyAMA0,115200 rootwait root=/dev/mmcblk0"  -net nic,model=lan9118 -net user  ${EXTRA_ARGS}

2.3 直接启动kernel on SD
qemu-system-arm \
    -M vexpress-a9 \
    -m 512M \
    -kernel zImage \
    -dtb vexpress-v2p-ca9.dtb \
    -nographic \
    -append "root=/dev/mmcblk0 rw console=ttyAMA0" \
    -sd vexpress.img
sudo qemu-system-arm -M vexpress-a9 -m 512M -kernel project_vexpress_ca9x4/arch/arm/boot/zImage -dtb project_vexpress_ca9x4/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "root=/dev/mmcblk0 rw console=ttyAMA0" -sd project_rootfs/vexpress.img
#-M 使用qemu 仿真vexpress-a9
#-m 指定qemu 虚拟机内存为 512M
#-kernel 指定qemu 使用的kernel image
#-dtb 指定qemu 引导 kernel 时使用的设备树
#-nographic 不使用图形界面, 使用串口输出。若使用lcd 版的qemu 需要去掉-nographic, 并且要把console=ttyAMA0 改为console=tty0 
#因为标准终端已经重定向到lcd, 设备也由/dev/ttyAMA0变成了/dev/tty0
#- append ”XX“ 指定kernel 启动参数, root=/dev/mmcblk0告诉kernel,  rootfs文件系统映像在 /dev/mmcblk0 以rw 方式挂载。这个选项
#配合 -sd工作, sd/emmc设备都是mmc 接口, mmc接口的第一个设备就是mmcblk0. -append 还可以更完善。比如： -append "init=/linuxrc root=/dev/mmcblk0 rw rootwait earlyprintk console=ttyAMA0"
#其中, init=/linuxrc 告诉kernel 起来后执行一下 /linuxrc。启动后报告 can't run ‘/etc/init.d/rcs'：no such file or directory, 这是linux 启动后执行的脚本, 我们可以创建这个文件（chmod 777）, 
#随后echo 任何东西。（etc 作为kernel 启动后的配置指示, 可以完善的更好,  etc.tar.gz）
#-sd 指定qemu 的硬件连接状态, 连接一个sd卡（mmc接口）, sd卡中的映像内容就是vexpress.img. 没有文件系统kernel 会打印kernel panic - not syncing ： VFS：unable to mount root fs on unknown-block(0,0)
#表示没有文件系统可以挂载, 配合-append 里的root=xxx使用

*******************************************************************
3. Busybox
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_rootfs menuconfig
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_rootfs
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_rootfs install

*******************************************************************
4. 退出qemu
ps -A | grep qemu-system-arm | awk '{print $1}' | xargs sudo kill -9 







sudo apt install tftpd-hpa tftp-hpa
mkdir -p /home/xxx/tftpboot
sudo vim /etc/default/tftpd-hpa
sudo service tftpd-hpa restart

# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/home/xpeng/Documents/Linux_learn/tftpboot"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="-l -c -s --secure"

***
TFTP_DIRECTORY 作为TFTP SERVER的目录，该目录需可读可写权限
TFTP_ADDRESS 为0.0.0.0:69 表示所有IP源都可以访问
TFTP_OPTIONS 为“-l -c -s” 其中
-l： 以standardalone/listen 模式启动TFTP服务，而不是从xinetd程序
-c: 可创建新文件。默认情况下TFTP只允许覆盖原有文件而不能创造新文件
-s：改变TFTP启动的根目录。客户端启动TFTP时，不再需要输入指定目录，填写文件的文件路径，而是使用配置文件写好的目录


