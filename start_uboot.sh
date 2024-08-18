# #!/bin/bash
# sudo qemu-system-arm \
#         -M vexpress-a9 \
#         -nographic \
#         -m 512M \
#         -kernel project_uboot/u-boot

#!/bin/bash
sudo qemu-system-arm \
        -M vexpress-a9 \
        -m 512M \
        -smp 1 \
        -nographic \
        -kernel project_uboot/u-boot \
        -sd project_rootfs/vexpress-ca9-next.img

# #查看u-boot 启动界面配置u-boot参数
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