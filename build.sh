#!/bin/bash
# (c) 2015, 2016, Leo Xu <otakunekop@banana-pi.org.cn>
# Build script for BPI-M2U-BSP 2016.09.10

export BOARD="sinlinx-a33-lcd5"
export TOPDIR=`pwd`
export OUT_DIR="pack-out/$BOARD"

export J=$(expr `grep ^processor /proc/cpuinfo  | wc -l` \* 2)


cp_download_files()
{
T="$TOPDIR"
SD="$T/SD/${board}"
U="${SD}/100MB"
B="${SD}/BPI-BOOT"
R="${SD}/BPI-ROOT"
	#
	## clean SD dir.
	#
	rm -rf $SD
	#
	## create SD dirs (100MB, BPI-BOOT, BPI-ROOT) 
	#
	mkdir -p $SD
	mkdir -p $U
	mkdir -p $B
	mkdir -p $R
	#
	## copy files to 100MB
	#
	cp -a $T/out/${TARGET_PRODUCT}/100MB/* $U
	#
	## copy files to BPI-BOOT
	#
	mkdir -p $B/bananapi/${board}
	type=$(echo ${BOARD/BPI-M2M-/} | tr '[A-Z]' '[a-z]')
	cp -a $T/sunxi-pack/allwinner/${TARGET_PRODUCT}/configs/default/linux $B/bananapi/${board}/linux/
	cp -a $T/linux-sunxi/arch/arm/boot/uImage $B/bananapi/${board}/linux/uImage

	#
	## copy files to BPI-ROOT
	#
	mkdir -p $R/usr/lib/u-boot/bananapi/${board}
	cp -a $U/*.gz $R/usr/lib/u-boot/bananapi/${board}/
	rm -rf $R/lib/modules
	mkdir -p $R/lib/modules
	cp -a $T/linux-sunxi/output/lib/modules/${kernel} $R/lib/modules
	#
	## create files for bpi-tools & bpi-migrate
	#
	(cd $B ; tar czvf $SD/BPI-BOOT-${board}.tgz .)
	(cd $R ; tar czvf $SD/${kernel}.tgz lib/modules)
	(cd $R ; tar czvf $SD/BOOTLOADER-${board}.tgz usr/lib/u-boot/bananapi)

	return #SKIP
}

#==========================================================================
build_uboot()
{
	echo "start build uboot..."
	if [ ! -d "$UBOOT_DIR" ]; then
		echo "error: uboot dir $UBOOT_DIR not exist."
		exit -1
	fi
	make -C $UBOOT_DIR ${UBOOT_CONFIG} CROSS_COMPILE=$UBOOT_CROSS_COMPILE -j$J
	make -C $UBOOT_DIR all CROSS_COMPILE=$UBOOT_CROSS_COMPILE -j$J
	cp -v $UBOOT_DIR/u-boot.bin $OUT_DIR
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
	cp -v $KERNEL_DIR/arch/arm/boot/zImage $OUT_DIR
	cp -v $KERNEL_DIR/arch/arm/boot/uImage $OUT_DIR
	cp -v $KERNEL_DIR/arch/arm/boot/Image $OUT_DIR/bImage
	gzip -c $KERNEL_DIR/usr/initramfs_data.cpio > $OUT_DIR/initramfs_data.cpio.gz
        mkbootimg --kernel $OUT_DIR/bImage \
                --ramdisk $OUT_DIR/initramfs_data.cpio.gz \
                --board 'karl' \
                --base 0x40000000 \
                -o $OUT_DIR/boot.img

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
#==========================================================================
if [ -d "pack-source/boards/$BOARD" ]; then
	echo "target board is $BOARD"
	export BOARD_TOP="`pwd`/pack-source/boards/$BOARD"
else
	echo "error: target board $BOARD not exist."
	echo "supported boards are:"
	(cd pack-source/boards; ls -1d *)
	exit -1
fi

if [ -f "$BOARD_TOP/build_env.sh" ];then
	. $BOARD_TOP/build_env.sh
else
	echo "error: cant find $BOARD_TOP/build_env.sh"
	exit -1
fi

if [ -d "$OUT_DIR" ]; then
	rm -rf "$OUT_DIR"
fi
mkdir -p "$OUT_DIR"
	
#==========================================================================
clean_uboot
#build_uboot

clean_kernel
#build_kernel

#=========================================================================
exit 1

echo "This tool support following building mode(s):"
echo "--------------------------------------------------------------------------------"
echo "	1. Build all, uboot and kernel and pack to download images."
echo "	2. Build uboot only."
echo "	3. Build kernel only."
echo "	4. kernel configure."
echo "	5. Pack the builds to target download image, this step must execute after u-boot,"
echo "	   kernel and rootfs build out"
echo "	6. update local build to SD with bpi image flashed"
echo "	7. Clean all build."
echo "--------------------------------------------------------------------------------"

if [ -z "$MODE" ]; then
	read -p "Please choose a mode(1-7): " mode
	echo
else
	mode=$MODE
fi

if [ -z "$mode" ]; then
        echo -e "\033[31m No build mode choose, using Build all default   \033[0m"
        mode=1
fi

echo -e "\033[31m Now building...\033[0m"
echo
case $mode in
	1) make && 
	   make pack && 
	   cp_download_files;;
	2) make u-boot;;
	3) make kernel;;
	4) make kernel-config;;
	5) make pack &&
	   cp_download_files;;
	6) make install;;
	7) make clean;;
esac
echo

echo -e "\033[31m Build success!\033[0m"
echo
