#!/bin/bash
# (c) 2015, Leo Xu <otakunekop@banana-pi.org.cn>
# Build script for BPI-M2P-BSP 2016.03.02

cp_download_files()
{
	. ./chosen_board.mk
	local pack_out=output/$BOARD/pack
	local download=download/$BOARD

	rm -rf $download
	mkdir -p $download/lib/modules

	cp $pack_out/boot0_sdcard.fex $download/
        cp $pack_out/u-boot.fex $download/
#        cp $pack_out/sunxi_mbr.fex $download/
#        cp $pack_out/boot-resource.fex $download/
#        cp $pack_out/env.fex $download/
#        cp $pack_out/boot.fex $download/
        cp -r linux-sunxi/output/lib/modules/* $download/lib/modules/
        cp -r linux-sunxi/arch/arm/boot/uImage $download/lib/modules/3.4.*
}

echo "=========================================="
echo -e "\033[41;37m            BPI-M2P BSP Build Tool         \033[0m"
echo "=========================================="
echo
echo "This tool support following BPI board(s):"
echo "------------------------------------------"
echo "	1. BPI_M2P_720P"
echo "	2. BPI_M2P_1080P"
echo "	3. BPI_M2P_USB_720P"
echo "	4. BPI_M2P_USB_1080P"
echo "------------------------------------------"

read -p "Please choose a target(1-4): " board
echo

if [ -z "$board" ]; then
	echo -e "\033[31m No target choose, using BPI_M2P_720P default   \033[0m"
	board=1
fi

echo
echo -e "\033[31m Now configuring...\033[0m"
echo
case $board in
	1) ./configure BPI_M2P_720P;;
	2) ./configure BPI_M2P_1080P;;
	3) ./configure BPI_M2P_USB_720P;;
	4) ./configure BPI_M2P_USB_1080P;;
esac
echo
echo -e "\033[31m Configure success!\033[0m"
echo

echo "This tool support following building mode(s):"
echo "--------------------------------------------------------------------------------"
echo "	1. Build all, uboot and kernel and pack to download images."
echo "	2. Build uboot only."
echo "	3. Build kernel only."
echo "	4. kernel configure."
echo "	5. Build rootfs for linux, and copy target files to output"
echo "		ROOTFS=/xxx/rootfs.tar.gz"
echo "		This is optinal, default using rootfs/linux/default_linux_rootfs.tar.gz."
echo "	6. Pack the builds to target download image, this step must execute after u-boot,"
echo "	   kernel and rootfs build out"
echo "	7. Clean all build."
echo "	8. update download dir."
echo "--------------------------------------------------------------------------------"

read -p "Please choose a mode(1-7): " mode
echo

if [ -z "$mode" ]; then
        echo -e "\033[31m No build mode choose, using Build all default   \033[0m"
        mode=1
fi

echo -e "\033[31m Now building...\033[0m"
echo
case $mode in
	1) make && 
	   make linux && 
	   make pack && 
	   cp_download_files;;
	2) make u-boot;;
	3) make kernel;;
	4) make kernel-config;;
	5) make linux;;
	6) make pack;;
	7) make clean;;
	8) cp_download_files;;
esac
echo

echo -e "\033[31m Build success!\033[0m"
echo
