#export BOARD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export J=$(expr `grep ^processor /proc/cpuinfo  | wc -l` \* 2)

export ARCH=arm
export MACH=sun8iw5p1
export PLATFORM=linux

export UBOOT_DIR=$TOP_DIR/u-boot-sunxi
export UBOOT_CONFIG=sun8iw5p1_config
export UBOOT_CROSS_COMPILE=arm-linux-gnueabi-

export KERNEL_DIR=$TOP_DIR/linux-sunxi
export KERNEL_CONFIG=sun8iw5p1smp_bpi_defconfig
export KERNEL_CROSS_COMPILE=arm-openwrt-linux-muslgnueabi-


export STAGING_DIR=$BOARD_DIR/pctools/arm-openwrt-linux-muslgnueabi-gcc-5.2.0
export PATH=$BOARD_DIR/pctools/arm-openwrt-linux-muslgnueabi-gcc-5.2.0/bin:$PATH
export PATH=$BOARD_DIR/pctools/arm-linux-gnueabi-gcc-4.6.3/bin:$PATH
export PATH=$BOARD_DIR/pctools/allwinner/mod_update:$PATH
export PATH=$BOARD_DIR/pctools/allwinner/eDragonEx:$PATH
export PATH=$BOARD_DIR/pctools/allwinner/fsbuild200:$PATH
export PATH=$BOARD_DIR/pctools/allwinner/android:$PATH
#=========================================================================
build_uboot()
{
        echo "start build uboot..."
        if [ ! -d "$UBOOT_DIR" ]; then
                echo "error: uboot dir $UBOOT_DIR not exist."
                exit -1
        fi
        make -C $UBOOT_DIR ${UBOOT_CONFIG} CROSS_COMPILE=$UBOOT_CROSS_COMPILE -j$J
        make -C $UBOOT_DIR all CROSS_COMPILE=$UBOOT_CROSS_COMPILE -j$J
        echo "build kernel end"
}
clean_uboot()
{
        echo "start clean uboot..."
        if [ ! -d "$UBOOT_DIR" ]; then
                echo "error: uboot dir $UBOOT_DIR not exist."
                exit -1
        fi
        make -C $UBOOT_DIR CROSS_COMPILE=$UBOOT_CROSS_COMPILE -j$J distclean
        echo "clean clean end"
}
build_kernel()
{
        echo "start build kernel..."
        if [ ! -d "$KERNEL_DIR" ]; then
                echo "error: kernel dir $KERNEL_DIR not exist."
                exit -1
        fi
        make -C $KERNEL_DIR ARCH=$ARCH $KERNEL_CONFIG
        make -C $KERNEL_DIR ARCH=$ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE -j$J INSTALL_MOD_PATH=output uImage
        make -C $KERNEL_DIR ARCH=$ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE -j$J INSTALL_MOD_PATH=output modules
        make -C $KERNEL_DIR ARCH=$ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE -j$J INSTALL_MOD_PATH=output modules_install

        echo "build kernel end"
}
clean_kernel()
{
        echo "start clean kernel..."
        if [ ! -d "$KERNEL_DIR" ]; then
                echo "error: kernel dir $KERNEL_DIR not exist."
                exit -1
        fi
        make -C $KERNEL_DIR ARCH=$ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE -j$J distclean
        rm -rf $KERNEL_DIR/output
        echo "clean kernel end"
}
pack_image()
{
        TEST_PACK=/home/karllee/alwinner/lichee/tools/pack
        #cp -v $UBOOT_DIR/u-boot.bin $OUT_DIR
        #cp -v $KERNEL_DIR/arch/arm/boot/zImage $OUT_DIR
        #cp -v $KERNEL_DIR/arch/arm/boot/uImage $OUT_DIR
        #cp -v $KERNEL_DIR/arch/arm/boot/Image $OUT_DIR/bImage
        #cp -v $KERNEL_DIR/drivers/arisc/binary/arisc $OUT_DIR/arisc.bin
        cp -v $BOARD_DIR/configs/arisc $OUT_DIR/arisc.fex
        cp -v /home/karllee/alwinner/lichee/linux-3.4/arch/arm/boot/Image $OUT_DIR/bImage
        #gzip -c $KERNEL_DIR/usr/initramfs_data.cpio > $OUT_DIR/rootfs.cpio.gz
        cp -v /home/karllee/alwinner/lichee/linux-3.4/rootfs.cpio.gz $OUT_DIR/rootfs.cpio.gz
        cp -v $BOARD_DIR/common/tools/* $OUT_DIR
        cp -v $BOARD_DIR/configs/image_linux.cfg $OUT_DIR/image.cfg
        #cp -v $BOARD_DIR/configs/sys_partition_linux.fex $OUT_DIR/sys_partition.fex
        #cp -v $BOARD_DIR/configs/sys_config.fex $OUT_DIR/sys_config.fex
        cp -v $BOARD_DIR/configs/env.cfg $OUT_DIR/env.cfg
        cp -v $BOARD_DIR/configs/boot0_nand_sun8iw5p1.bin $OUT_DIR/boot0_nand.fex
        cp -v $BOARD_DIR/configs/boot0_sdcard_sun8iw5p1.bin $OUT_DIR/boot0_sdcard.fex
        cp -v $BOARD_DIR/configs/fes1_sun8iw5p1.bin $OUT_DIR/fes1.fex
        cp -v /home/karllee/alwinner/lichee/tools/pack/chips/sun8iw5p1/bin/u-boot-sun8iw5p1.bin $OUT_DIR/u-boot.fex
        #cp -v $BOARD_DIR/configs/boot-resource.ini $OUT_DIR/boot-resource.ini
        #cp -rv $BOARD_DIR/configs/boot-resource $OUT_DIR

        cd $OUT_DIR
        mkbootimg --kernel bImage --ramdisk rootfs.cpio.gz --board 'a31' --base 0x40000000 -o boot.img
        #busybox unix2dos $BOARD_DIR/configs/sys_config.fex sys_config.fex
        unix2dos -n $TEST_PACK/chips/sun8iw5p1/configs/sinlinx/sys_config.fex sys_config.fex
        unix2dos -n $BOARD_DIR/configs/sys_partition_linux.fex sys_partition.fex
        script sys_config.fex
        script sys_partition.fex
        cp -v sys_config.bin config.fex
        update_boot0 boot0_nand.fex sys_config.bin NAND
        update_boot0 boot0_sdcard.fex sys_config.bin SDMMC_CARD
        update_uboot u-boot.fex sys_config.bin
        update_fes1 fes1.fex sys_config.bin
        update_mbr sys_partition.bin 4
        #fsbuild boot-resource.ini split_xxxx.fex
        u_boot_env_gen env.cfg env.fex
        dragon image.cfg sys_partition.fex
        cd $TOP_DIR
}

#=========================================================================
