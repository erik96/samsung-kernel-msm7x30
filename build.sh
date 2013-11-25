#!/bin/sh

BASE_PHENOM_VER=$(head -n 1 phenom.version)

# Build Environment
export ARCH=arm
export CROSS_COMPILE=/home/erik/android/kernel/toolchains/arm-cortex_a8-linux-gnueabi-linaro_4.8.3-2013.11/bin/arm-cortex_a8-linux-gnueabi-

make "clean"
echo '\n'$BASE_PHENOM_VER 
echo ""
echo "\nMaking defconfig\n"

DATE_START=$(date +"%s")

# Make Defconfig
make "ariesve_erik_defconfig"

# Build Kernel
echo "\nBuilding Kernel\n"

IMAGE_DIR=../output/cm11.0/zImage
MODULE_DIR=../output/cm11.0/out/system/lib/modules/
RAMDISK_DIR=../output/cm11.0/ramdisk/
KERNEL_DIR=out

make "-j5"
echo
cp arch/arm/boot/zImage $IMAGE_DIR
find . -name "*.ko" -exec cp {} $MODULE_DIR \;
cd $RAMDISK_DIR
find . | cpio -o -H newc | gzip > ../newramdisk.cpio.gz
cd ../

./mkbootimg --kernel zImage --ramdisk newramdisk.cpio.gz --base 0x00400000 --pagesize 4096  --cmdline 'no_console_suspend=1 console=bull's -o boot.img

cp boot.img $KERNEL_DIR

echo "\nZipping package\n"

cd $KERNEL_DIR
zip -r $BASE_PHENOM_VER.zip *
#cd ../

#echo "\nSigning package\n"

#cp $KERNEL_DIR/$BASE_PHENOM_VER.zip zip
#cd zip
#java -classpath testsign.jar testsign $BASE_PHENOM_VER.zip $BASE_PHENOM_VER-ariesve_signed.zip

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "\nBuild completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.\n"
