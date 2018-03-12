@echo off

if exist BrownieOS.img del BrownieOS.img

echo The BrownieOS Build Script!

echo Assembling the bootloader...
fasm FAT12_BOOT.ASM

echo Assembling the kernel...
fasm KERNEL.ASM

echo Creating the floppy disk...
fat_imgen -c -f BrownieOS.img

echo Copying the bootloader to the floppy disk...
fat_imgen -m -f BrownieOS.img -s FAT12_BOOT.BWN

echo Copying the kernel to the floppy disk...
fat_imgen -m -f BrownieOS.img -i KERNEL.BWN

echo Cleaning up build...
del *.BWN

echo Done!
