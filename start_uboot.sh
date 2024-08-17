#!/bin/bash
# sudo qemu-system-arm \
#         -M vexpress-a9 \
#         -nographic \
#         -m 512M \
#         -kernel project_uboot/u-boot

#!/bin/bash
sudo qemu-system-arm \
        -M vexpress-a9 \
        -m 512M \
        -nographic \
        -kernel project_uboot/u-boot \
        -sd project_rootfs/vexpress-ca9-next.img