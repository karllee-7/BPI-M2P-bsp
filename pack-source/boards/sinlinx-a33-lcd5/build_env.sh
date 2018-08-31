export BOARD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export ARCH=arm
export MACH=sun8iw5p1
export PLATFORM=linux

export UBOOT_DIR=u-boot-sunxi
export UBOOT_CONFIG=sun8iw5p1_config
export UBOOT_CROSS_COMPILE=arm-linux-gnueabi-

export KERNEL_DIR=linux-sunxi
export KERNEL_CONFIG=sun8iw5p1smp_bpi_defconfig
export KERNEL_CROSS_COMPILE=arm-openwrt-linux-muslgnueabi-


export STAGING_DIR=$BOARD_DIR/pctools/arm-openwrt-linux-muslgnueabi-gcc-5.2.0
export PATH=$BOARD_DIR/pctools/arm-openwrt-linux-muslgnueabi-gcc-5.2.0/bin:$PATH
export PATH=$BOARD_DIR/pctools/arm-linux-gnueabi-gcc-4.6.3/bin:$PATH
export PATH=$BOARD_DIR/pctools/linux/mod_update:$PATH
export PATH=$BOARD_DIR/pctools/linux/eDragonEx:$PATH
export PATH=$BOARD_DIR/pctools/linux/fsbuild200:$PATH
export PATH=$BOARD_DIR/pctools/linux/android:$PATH

