# BPI-M2P-bsp

Getting Started
---------------

1. Choose a board doing:
   `./build.sh`,

2. Choose a board doing

"This tool supports the following BPI board(s):"

************************************************"

	1. BPI-M2P-720P"

	2. BPI-M2P-1080P"
	
	3. BPI-M2P-USB-720P"
	
	4. BPI-M2P-USB-1080P"
	
*************************************************"


BPI-M2P SD Card Info
--------------------

Step 1.To be on safe side erase the first part of your SD Card (also clears the partition table).


       sudo  dd if=/dev/zero of=${card} bs=1M count=1

Step 2.Go to folder "Download", put the file(s) to 100MB of the SD Card with DD command.



	sudo dd if=boot0_sdcard.fex     of=${card} bs=1k seek=8

	sudo dd if=u-boot.fex 	        of=${card} bs=1k seek=16400

	sudo dd if=sunxi_mbr.fex    of=${card} bs=1k seek=20480

	sudo dd if=boot-resource.fex    of=${card} bs=1k seek=36864

	sudo dd if=env.fex          of=${card} bs=1k seek=69632
	

Overview
--------

ref. from https://github.com/loboris/OrangePI-Kernel.git
Thanks Boris Lovosevic

You may go to http://www.banana-pi.org to download Ubuntu15.10 images and burn them into the Sdcard to see the architecture.





