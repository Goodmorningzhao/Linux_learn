# Linux_learn
***************************************************************************************
1. u-boot
mkdir project_uboot
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./../project_uboot distclean
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./../project_uboot vexpress_ca9x4_defconfig //配置
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./../project_uboot  //编译
1.1 直接启动u-boot 
qemu-system-arm -M vexpress-a9 \
     -kernel u-boot \
     -nographic \
     -m 512M
***************************************************************************************
2. Kernel
mkdir project_kernel
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm  O=./project_kernel distclean
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel vexpress_defconfig
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel menuconfig
2.1.1
$ make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel zImage -j2
2.1.2
$ make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel modules -j2
2.1.3
$ make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel dtbs -j2
2.1.4
$ make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_kernel LOADADDR=0x60003000 uImage  -j2
2.2 直接启动kernel
qemu-system-arm \
      -M vexpress-a9 \
      -m 512M \
      -nographic \
      -kernel project_kernel/arch/arm/boot/zImage \
      -dtb project_kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
      -append "root=/dev/mmcblk0 rw console=ttyAMA0" 
***然而，运行开始后却提示end kernel panic - not syncing: VFS:Unable to mount root fs on unknown-block 无文件系统
***************************************************************************************
3. Busybox
mkdir project_rootfs
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_rootfs distclean
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_rootfs menuconfig
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_rootfs
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm O=./project_rootfs install
***关于制作文件系统，请参考start_rootfs.sh
***************************************************************************************
4. 退出qemu
ps -A | grep qemu-system-arm | awk '{print $1}' | xargs sudo kill -9 
***************************************************************************************
5. Knowledge
Image：内核映像文件，大约为4M；
zImage：内核的一种映像压缩文件，不到2M；内核编译（make）之后会生成Image和zImage；
uImage：u-boot专用的映像文件，它是在zImage之前加上一个长度为64字节的“头”，说明这个内核的版本、加载位置、生成时间、大小等信息，在0x40之后与zImage没有任何区别。

5.1 安装TFTP Server
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

5.2 QEMU 参数
#-M 使用qemu 仿真vexpress-a9
#-m 指定qemu 虚拟机内存为 512M
#-kernel 指定qemu 使用的kernel image
#-dtb 指定qemu 引导 kernel 时使用的设备树
#-nographic 不使用图形界面, 使用串口输出。若使用lcd 版的qemu 需要去掉-nographic, 并且要把console=ttyAMA0 改为console=tty0 
#因为标准终端已经重定向到lcd, 设备也由/dev/ttyAMA0变成了/dev/tty0
#- append ”XX“ 指定kernel 启动参数, root=/dev/mmcblk0告诉kernel,  rootfs文件系统映像在 /dev/mmcblk0 以rw 方式挂载。这个选项 \
#配合 -sd工作, sd/emmc设备都是mmc 接口, mmc接口的第一个设备就是mmcblk0. -append 还可以更完善。比如： -append "init=/linuxrc root=/dev/mmcblk0 rw rootwait earlyprintk console=ttyAMA0" \
#其中, init=/linuxrc 告诉kernel 起来后执行一下 /linuxrc。启动后报告 can't run ‘/etc/init.d/rcs'：no such file or directory, 这是linux 启动后执行的脚本, 我们可以创建这个文件（chmod 777）, \
#随后echo 任何东西。（etc 作为kernel 启动后的配置指示, 可以完善的更好,  etc.tar.gz）
#-sd 指定qemu 的硬件连接状态, 连接一个sd卡（mmc接口）, sd卡中的映像内容就是vexpress.img. 没有文件系统kernel 会打印kernel panic - not syncing ： VFS：unable to mount root fs on unknown-block(0,0) \
#表示没有文件系统可以挂载, 配合-append 里的root=xxx使用

5.3 编译器的差异
交叉编译器 arm-linux-gnueabi 和 arm-linux-gnueabihf 分别适用于 armel 和 armhf 两个不同的架构。而这两种架构在对待浮点运算采取了不同的策略（有 fpu 的 arm 才能支持这两种浮点运算策略）。
这两个编译器只是在处理是 gcc 的选项 -mfloat-abi 的默认值不同。gcc 的选项 -mfloat-abi 有三种值 soft、softfp、hard（其中后两者都要求arm 里有 fpu 浮点运算单元，soft 与后两者是兼容的，但 softfp 和 hard 两种模式互不兼容）：
soft： 不用fpu进行浮点计算，即使有fpu浮点运算单元也不用，而是使用软件模式。
softfp： armel架构（对应的编译器为 arm-linux-gnueabi-gcc ）采用的默认值，用fpu计算，但是传参数用普通寄存器传，这样中断的时候，只需要保存普通寄存器，中断负荷小，但是参数需要转换成浮点的再计算。
hard： armhf架构（对应的编译器 arm-linux-gnueabihf-gcc ）采用的默认值，用fpu计算，传参数也用fpu中的浮点寄存器传，省去了转换，性能最好，但是中断负荷高

5.4 安装多体系结构支持的GDB
sudo apt install gdb-multiarch
sudo qemu-system-arm -M vexpress-a9 -nographic -m 512M  -kernel project_uboot/u-boot -gdb tcp::1234 -S
其中-S 让QEMU 开机后由gdb控制，即暂停CPU直到触发gdb命令启动运行。
与此同时，在另一个终端用以下命令：
gdb-multiarch u-boot -ex "target remote localhost:1234" 可以开始追踪u-boot启动过程，QEMU为调试u-boot，linux 内核提供便利，同时也方便对启动过程，内核原理的理解

5.5 将编译好的程序拷贝至镜像文件,用于测试程序运行浮点运算效率。
sudo mount -t ext3 vexpress.img tmpfs -o loop
sudo cp test/mfloat/mfloat* tmpfs/root/
sudo umount tmpfs
time ./mfloat  
time ./mfloat-hf