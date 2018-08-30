
export ARCH=arm
export MACH=sun8iw5p1
export PLATFORM=linux

export UBOOT_DIR=u-boot-sunxi
export UBOOT_CONFIG=sun8iw5p1_config
export UBOOT_CROSS_COMPILE=arm-linux-gnueabi-

export KERNEL_DIR=linux-sunxi
export KERNEL_CONFIG=sun8iw5p1smp_bpi_defconfig
export KERNEL_CROSS_COMPILE=arm-openwrt-linux-muslgnueabi-

export STAGING_DIR=$TOPDIR/pack-source/tools/arm-openwrt-linux-muslgnueabi
export PATH=$TOPDIR/pack-source/tools/arm-openwrt-linux-muslgnueabi-gcc-5.2.0/bin:$TOPDIR/pack-source/tools/arm-linux-gnueabi-gcc-4.6.3/bin:$TOPDIR/pack-source/tools/allwinner-tools/bin:$PATH


