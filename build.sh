#!/bin/bash

export BOARD="sinlinx-a33-lcd5"
export TOP_DIR=`pwd`
#==========================================================================
if [ ! -d "pack-source/boards/$BOARD" ]; then
	echo "error: target board $BOARD not exist."
	echo "supported boards are:"
	(cd pack-source/boards; ls -1d *)
	exit -1
fi

if [ ! -f "pack-source/boards/$BOARD/build_env.sh" ]; then
	echo "error: target board $BOARD/build_env.sh not exist."
	exit -1
fi

export BOARD_DIR="$TOP_DIR/pack-source/boards/$BOARD"
export OUT_DIR="$TOP_DIR/pack-out/$BOARD"
echo "target board is $BOARD, path is $BOARD_DIR"

. $BOARD_DIR/build_env.sh
[ -d "$OUT_DIR" ] && rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
	
#==========================================================================
clean_uboot
#build_uboot

clean_kernel
#build_kernel
set -x
#pack_image
#=========================================================================
exit 1

echo "This tool support following building mode(s):"
echo "--------------------------------------------------------------------------------"
echo "	1. Build all, uboot and kernel and pack images."
echo "	2. Build uboot only."
echo "	3. Build kernel only."
echo "	4. kernel configure."
echo "	5. Pack the builds to target image, this step must execute after u-boot,"
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
