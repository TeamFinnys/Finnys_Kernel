#!/bin/bash

printf '\033]2;%s\007' "Building Kernel"

# Cleaning
echo ""
echo "Cleaning Temp Files"
if [ -e anykernel/tmp/anykernel/zImage ]; then
   rm -rf anykernel/tmp/anykernel/zImage
fi
if [ -e anykernel/*.zip ]; then
   rm -rf anykernel/*.zip
fi

if [ $# -gt 0 ]; then
   echo $1 > .version
fi

export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=~/android/toolchain/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-
#export CONFIG_NO_ERROR_ON_MISMATCH=y

make finnys_defconfig
#make mako_defconfig

make -j4

# Moves zImage to anykernel dir
if [ -e arch/arm/boot/zImage ]; then
   echo ""
   echo "Moving zImage"
   cp arch/arm/boot/zImage anykernel/tmp/anykernel/
fi

# Make flashable zip
if [ -e anykernel/tmp/anykernel/zImage ]; then
   echo ""
   echo "Making Zip File"
   zipfile=Finnys-Kernel-r$(cat .version).zip
   cd anykernel
   rm -f *.zip
   zip -r $zipfile *
   cp *.zip ../
fi

cd ../

# Cleaning
echo ""
echo "Cleaning Temp Files"
if [ -e anykernel/tmp/anykernel/zImage ]; then
   rm -rf anykernel/tmp/anykernel/zImage
fi
if [ -e anykernel/*.zip ]; then
   rm -rf anykernel/*.zip
fi

echo ""
echo "DONE!!!!"
read
