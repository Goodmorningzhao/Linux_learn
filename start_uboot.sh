#!/bin/bash
sudo qemu-system-arm \
        -M vexpress-a9 \
        -nographic \
        -m 512M \
        -kernel project_uboot/u-boot