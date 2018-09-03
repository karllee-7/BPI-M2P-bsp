#export BOARD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export J=$(expr `grep ^processor /proc/cpuinfo  | wc -l` \* 2)

export ARCH=arm
export MACH=sun8iw5p1
export PLATFORM=linux
export ROOTFS_SIZE=512

export UBOOT_DIR=$TOP_DIR/u-boot-sunxi
export UBOOT_CONFIG=sun8iw5p1_config
export UBOOT_CROSS_COMPILE=arm-linux-gnueabi-

export KERNEL_DIR=$TOP_DIR/linux-sunxi
export KERNEL_CONFIG=sun8iw5p1smp_bpi_defconfig
export KERNEL_CROSS_COMPILE=arm-openwrt-linux-muslgnueabi-

export STAGING_DIR=$TOP_DIR/pack-source/pctools/arm-openwrt-linux-muslgnueabi-gcc-5.2.0
export PATH=$TOP_DIR/pack-source/pctools/arm-openwrt-linux-muslgnueabi-gcc-5.2.0/bin:$PATH
export PATH=$TOP_DIR/pack-source/pctools/arm-linux-gnueabi-gcc-4.6.3/bin:$PATH
export PATH=$BOARD_DIR/pctools/mod_update:$PATH
export PATH=$BOARD_DIR/pctools/eDragonEx:$PATH
export PATH=$BOARD_DIR/pctools/fsbuild200:$PATH
export PATH=$BOARD_DIR/pctools/android:$PATH
#=========================================================================
build_gpu()
{
	echo -e "\033[33minfo start build gpu...\033[0m"
	MALI_DRV_ROOT=$KERNEL_DIR/modules/mali/DX910-SW-99002-r3p2-01rel1/driver/src/devicedrv/mali
	MALI_UMP_ROOT=$KERNEL_DIR/modules/mali/DX910-SW-99002-r3p2-01rel1/driver/src/devicedrv/ump
	mali_output_dir=output/lib/modules/3.4.39-BPI-M2M-Kernel/kernel/drivers/gpu
	make -C ${MALI_UMP_ROOT} CONFIG=ca8-virtex820-m400-1 BUILD=release KDIR=${KERNEL_DIR} \
		CROSS_COMPILE=$KERNEL_CROSS_COMPILE
	make -C ${MALI_DRV_ROOT} USING_MMU=1 USING_UMP=0 USING_PMM=1 BUILD=release \
		KDIR=${KERNEL_DIR} CROSS_COMPILE=$KERNEL_CROSS_COMPILE
	[ ! -d "$KERNEL_DIR/$mali_output_dir" ] && mkdir -p $KERNEL_DIR/$mali_output_dir
	cp -v $MALI_UMP_ROOT/ump.ko $KERNEL_DIR/$mali_output_dir
	cp -v $MALI_DRV_ROOT/mali.ko $KERNEL_DIR/$mali_output_dir
	echo -e "\033[33minfo build gpu end\033[0m"
}
clean_gpu()
{
	echo -e "\033[33minfo start clean gpu...\033[0m"
	MALI_DRV_ROOT=$KERNEL_DIR/modules/mali/DX910-SW-99002-r3p2-01rel1/driver/src/devicedrv/mali
	MALI_UMP_ROOT=$KERNEL_DIR/modules/mali/DX910-SW-99002-r3p2-01rel1/driver/src/devicedrv/ump
	make -C ${MALI_UMP_ROOT} CONFIG=ca8-virtex820-m400-1 BUILD=release \
		KDIR=${KERNEL_DIR} CROSS_COMPILE=$KERNEL_CROSS_COMPILE clean
	make -C ${MALI_DRV_ROOT} USING_MMU=1 USING_UMP=0 USING_PMM=1 BUILD=release \
		KDIR=${KERNEL_DIR} CROSS_COMPILE=$KERNEL_CROSS_COMPILE clean
	echo -e "\033[33minfo clean gpu end\033[0m"
}
#=========================================================================
build_uboot()
{
        echo -e "\033[33minfo: start build uboot...\033[0m"
        if [ ! -d "$UBOOT_DIR" ]; then
                echo -e "\033[31merror: uboot dir $UBOOT_DIR not exist.\033[0m"
                exit -1
        fi
        make -C $UBOOT_DIR ${UBOOT_CONFIG} CROSS_COMPILE=$UBOOT_CROSS_COMPILE -j$J
        make -C $UBOOT_DIR all CROSS_COMPILE=$UBOOT_CROSS_COMPILE -j$J
        echo -e "\033[33minfo: build kernel end \033[0m"
}
clean_uboot()
{
        echo -e "\033[33minfo: start clean uboot...\033[0m"
        if [ ! -d "$UBOOT_DIR" ]; then
                echo -e "\033[31merror: uboot dir $UBOOT_DIR not exist.\033[0m"
                exit -1
        fi
        make -C $UBOOT_DIR CROSS_COMPILE=$UBOOT_CROSS_COMPILE -j$J distclean
        echo -e "\033[33minfo: clean clean end\033[0m"
}
build_kernel()
{
        echo -e "\033[33minfo: start build kernel...\033[0m"
        if [ ! -d "$KERNEL_DIR" ]; then
                echo -e "\033[31merror: kernel dir $KERNEL_DIR not exist.\033[0m"
                exit -1
        fi
        make -C $KERNEL_DIR ARCH=$ARCH $KERNEL_CONFIG
        make -C $KERNEL_DIR ARCH=$ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE -j$J INSTALL_MOD_PATH=output uImage
        make -C $KERNEL_DIR ARCH=$ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE -j$J INSTALL_MOD_PATH=output modules
        make -C $KERNEL_DIR ARCH=$ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE -j$J INSTALL_MOD_PATH=output modules_install
	build_gpu

        echo -e "\033[33minfo: build kernel end\033[0m"
}
clean_kernel()
{
        echo -e "\033[33minfo: start clean kernel...\033[0m"
        if [ ! -d "$KERNEL_DIR" ]; then
                echo -e "\033[31merror: kernel dir $KERNEL_DIR not exist.\033[0m"
                exit -1
        fi
	clean_gpu
        make -C $KERNEL_DIR ARCH=$ARCH CROSS_COMPILE=$KERNEL_CROSS_COMPILE -j$J distclean
        rm -rf $KERNEL_DIR/output
        echo -e "\033[33minfo: clean kernel end\033[0m"
}
pack_image()
{

        echo -e "\033[33minfo: start pack image...\033[0m"
	[ -d "$OUT_DIR" ] && rm -rf "$OUT_DIR"
	mkdir -p "$OUT_DIR"
	#================================================================================
        cp -v $UBOOT_DIR/u-boot.bin $OUT_DIR/u-boot.fex
        #cp -v $KERNEL_DIR/arch/arm/boot/zImage $OUT_DIR
        #cp -v $KERNEL_DIR/arch/arm/boot/uImage $OUT_DIR/uImage.fex
        cp -v $KERNEL_DIR/arch/arm/boot/Image $OUT_DIR/bImage
        cp -v $KERNEL_DIR/drivers/arisc/binary/arisc $OUT_DIR/arisc.fex
        gzip -c $KERNEL_DIR/usr/initramfs_data.cpio > $OUT_DIR/rootfs.cpio.gz
        cp -v $BOARD_DIR/common/tools/* $OUT_DIR
        cp -v $BOARD_DIR/configs/image_linux.cfg $OUT_DIR/image.cfg
        cp -v $BOARD_DIR/configs/sys_partition_linux.fex $OUT_DIR/sys_partition.fex
        cp -v $BOARD_DIR/configs/sys_config.fex $OUT_DIR/sys_config.fex
        cp -v $BOARD_DIR/configs/env.cfg $OUT_DIR/env.cfg
        cp -v $BOARD_DIR/configs/boot0_nand_sun8iw5p1.bin $OUT_DIR/boot0_nand.fex
        cp -v $BOARD_DIR/configs/boot0_sdcard_sun8iw5p1.bin $OUT_DIR/boot0_sdcard.fex
        cp -v $BOARD_DIR/configs/fes1_sun8iw5p1.bin $OUT_DIR/fes1.fex
        cp -v $BOARD_DIR/configs/boot-resource.ini $OUT_DIR
        cp -rv $BOARD_DIR/configs/boot-resource $OUT_DIR
        #cp -rv $BOARD_DIR/configs/rootfs.ext4 $OUT_DIR/rootfs.fex
	#================================================================================
        cd $OUT_DIR
        mkbootimg \
		--kernel bImage \
		--ramdisk rootfs.cpio.gz \
		--board 'a33' \
		--base 0x40000000 \
		-o boot.fex

        unix2dos sys_config.fex
        unix2dos sys_partition.fex
        script sys_config.fex
        script sys_partition.fex
        cp -v sys_config.bin config.fex
        update_boot0 boot0_nand.fex sys_config.bin NAND
        update_boot0 boot0_sdcard.fex sys_config.bin SDMMC_CARD
        update_uboot u-boot.fex sys_config.bin
        update_fes1 fes1.fex sys_config.bin
        update_mbr sys_partition.bin 4
        fsbuild boot-resource.ini split_xxxx.fex
        u_boot_env_gen env.cfg env.fex
	#================================================================================
	set -x
	[ ! -d rootfs_tmp ] && mkdir rootfs_tmp
	dd if=/dev/zero of=rootfs.fex bs=1M count=$ROOTFS_SIZE
	lodev=`sudo losetup -f --show rootfs.fex`
	sudo mkfs.ext4 -O ^metadata_csum,^64bit $lodev
	sudo mount $lodev rootfs_tmp
	sudo cp -a $BOARD_DIR/rootfs/* rootfs_tmp/
	sudo cp -a $KERNEL_DIR/output/* rootfs_tmp/
	sudo umount $lodev
	sudo losetup -d $lodev
	rm -r rootfs_tmp
	set +x
	#================================================================================
	sed -i 's/^imagename/;imagename/g' image.cfg
	image_name="${BOARD}-`date "+%Y%m%d%H%M%S"`.img"
	echo "imagename=$image_name" >> image.cfg
	echo "" >> image.cfg
	#================================================================================
        dragon image.cfg sys_partition.fex
        echo -e "\033[32m`pwd`/$image_name\033[0m"
        cd $TOP_DIR
        echo -e "\033[33minfo: pack image end\033[0m"
}

clean_all()
{
	clean_uboot
	clean_kernel
	[ -d "$OUT_DIR" ] && rm -rfv "$OUT_DIR"

}
#=========================================================================
