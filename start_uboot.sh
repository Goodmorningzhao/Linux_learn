# #!/bin/bash
# sudo qemu-system-arm \
#         -M vexpress-a9 \
#         -nographic \
#         -m 512M \
#         -kernel project_uboot/u-boot
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# #!/bin/bash
# sudo qemu-system-arm \
#         -M vexpress-a9 \
#         -nographic \
#         -m 512M \
#         -kernel project_kernel/arch/arm/boot/zImage \
#         -dtb project_kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
#         -net tap,ifname=tap0,script=no,downscript=no -net nic,macaddr=00:16:3e:00:00:80 \
#         -append "root=/dev/nfs rw nfsroot=172.16.145.128:/mnt/rootfs,proto=tcp,nfsvers=3,nolock init=/linuxrc console=ttyAMA0 ip=172.16.145.129"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# #!/bin/bash
# sudo qemu-system-arm \
#         -M vexpress-a9 \
#         -m 512M \
#         -nographic \
#         -kernel project_kernel/arch/arm/boot/zImage \
#         -dtb project_kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
#         -append "root=/dev/mmcblk0 rw console=ttyAMA0" \
#         -sd project_rootfs/vexpress-ca9.img
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# #!/bin/bash
# sudo qemu-system-arm \
#         -M vexpress-a9 \
#         -nographic \
#         -m 512M \
#         -kernel project_uboot/u-boot \
#         -smp 1 \
#         -sd project_rootfs/vexpress-ca9-next.img
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# => part list mmc 0
# #查看磁盘内容
# => ls mmc 0:1
# => ls mmc 0:2
# #从SD开始加载内核、设备树到指定内存
# => load  mmc 0:1 0x60003000 uImage
# => load  mmc 0:2 0x60800000 vexpress-v2p-ca9.dtb
# #设置bootargs
# => setenv bootargs 'root=/dev/mmcblk0p2 rw rootfstyp3=ext3 rootwait earlycon console=ttyAMA0 init=/linuxrc ignore_loglevel'
# #启动内核
# => bootm 0x60003000 - 0x60800000
# 修改u-boot启动参数bootargs
# #define CONFIG_BOOTCOMMAND "load mmc 0:1 0x60003000 uImage;" \
# "load mmc 0:2 0x60800000 vexpress-v2p-ca9.dtb;" \
# "setenv bootargs 'root=/dev/mmcblk0p2 rw rootfstyp3=ext3 rootwait earlycon console=ttyAMA0 init=/linuxrc ignore_loglevel' \
# "bootm 0x60003000 - 0x60800000;"

#define CONFIG_BOOTCOMMAND "load mmc 0:1 0x60003000 uImage;" \
"load mmc 0:2 0x60800000 vexpress-v2p-ca9.dtb;" \
"setenv bootargs 'root=/dev/mmcblk0p2 rw rootfstyp3=ext3 rootwait earlycon console=ttyAMA0 init=/linuxrc ignore_loglevel' \
"bootm 0x60003000 - 0x60800000;"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# #!/bin/bash
# sudo qemu-system-arm \
#         -M vexpress-a9 \
#         -nographic \
#         -m 512M \
#         -kernel project_uboot/u-boot \
#         -net tap,ifname=tap0,script=no,downscript=no -net nic,macaddr=00:16:3e:00:00:80 \
#         -sd project_rootfs/vexpress-ca9-next.img
setenv bootargs 'root=/dev/nfs rw nfsroot=172.16.145.128:/mnt/rootfs,proto=tcp,nfsvers=3,nolock init=/linuxrc console=ttyAMA0 ip=172.16.145.129"
setenv ipaddr 172.16.145.129
setenv serverip 172.16.145.128
serenv netmask 255.255.255.0

saveenv #会出错，因为u-boot默认的参数保存位置FLASH，模拟器没有实现。但实际的开发板可以保存。
tftp 60003000 uImage
tftp 60800000 vexpress-v2p-ca9.dtb
bootm 60003000  - 60800000

或者按照以下步骤：
u-boot/configs/vexpress_ca9x4_defconfig
vim uboot/configs/vexpress_ca9x4_defconfig
# 将CONFIG_BOOTCOMMAND的值修改为：
CONFIG_BOOTCOMMAND=“tftp 0x60003000 uImage; \
tftp 0x60800000 vexpress-v2p-ca9.dtb; \
setenv bootargs 'root=/dev/nfs rw \
  nfsroot=172.16.145.128:/mnt/rootfs,proto=tcp,nfsvers=3,nolock \
  init=/linuxrc ip=172.16.145.129 console=ttyAMA0';\
  bootm 0x60003000 - 0x60800000;"

#u-boot/include/configs/vexpress_common.h
vim uboot/include/configs/vexpress_common.h
#在文件末尾#endif 之前添加如下内容：
#define CONFIG_IPADDR 172.16.145.129
#define CONFIG_NETMASK 255.255.255.0
#define CONFIG_SERVERIP 172.16.145.128
#########################################################################################################

*** 开启Qemu的网络支持功能, 启动u-boot, 设置u-boot的环境变量, u-boot采用tftp的方式将uImage格式的Linux内核下载到内存地址0x60003000处
***为什么是0x60000000起始的地址, 参考文件u-boot的配置文件 include/configs/vexpress_common.h
***如果用Qemu直接启动Kernel, 是通过-append parameter 的方式给kernel传参的
***现在是通过u-boot, 那么需要通过u-boot的环境变量bootargs
***可以设置为如下值 setenv bootargs 'root=/dev/mmcblk0 console=ttyAMA0 console=tty0'
***然后设置u-boot环境变量bootcmd, 如下: setenv bootcmd 'tftp 0x60003000 uImage; bootm 0x60003000'

