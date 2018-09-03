#!/bin/bash

set -e
#set -x

export TOP_DIR=`pwd`
export BOARD_BASE=$TOP_DIR/pack-source/boards
#==========================================================================
boards_list=(`(cd $BOARD_BASE && ls -d *)`)
echo "support following boards"
echo "-----------------------------------------------------------------------------"
for((i=0;i<${#boards_list[*]};i++)); do
	echo "$i. ${boards_list[$i]}"
done
echo "-----------------------------------------------------------------------------"
read -p "please choose a board: " i
if [ -z "$i" ] || [ ! $i -lt ${#boards_list[*]} ]; then
	echo -e "\033[31merror: invalid value\033[0m"
	exit 1
fi
export BOARD=${boards_list[$i]}
export BOARD_DIR="$BOARD_BASE/$BOARD"
export OUT_DIR="$TOP_DIR/pack-out/$BOARD"

if [ ! -f "pack-source/boards/$BOARD/build_env.sh" ]; then
	echo -e "\033[31merror: target board $BOARD/build_env.sh not exist. \033[0m"
	exit -1
fi

echo -e "\033[33minfo: target board is $BOARD\033[0m"
echo -e "\033[33minfo: output path is $OUT_DIR\033[0m"

. $BOARD_DIR/build_env.sh
#==========================================================================
#clean_uboot
#build_uboot

#clean_kernel
#build_kernel
#set -x
#pack_image
#=========================================================================
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

read -p "Please choose a mode(1-7): " mode

if [ -z "$mode" ]; then
        echo -e "\033[31merror: No build mode choose, using Build all default \033[0m"
	exit 1
fi

echo -e "\033[33mNow building...\033[0m"
case $mode in
	1) build_uboot && 
	   build_kernel && 
	   pack_image;;
	2) build_uboot;;
	3) build_kernel;;
	4) ;;
	5) pack_image;;
	6) ;;
	7) clean_all;;
esac
echo

echo -e "\033[33m Build success!\033[0m"
echo
