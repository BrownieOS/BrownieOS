@echo off

if exist BrownieOS.img del BrownieOS.img

echo The BrownieOS Build Script!

echo Assembling the bootloader...
fasm boot_floppy.asm

echo Assembling the kernel...
fasm kernel.asm

echo Creating the floppy disk...
fat_imgen -c -f BrownieOS.img

echo Copying the bootloader to the floppy disk...
fat_imgen -m -f BrownieOS.img -s boot_floppy.bwn

echo Copying the kernel to the floppy disk...
fat_imgen -m -f BrownieOS.img -i kernel.bwn

echo Cleaning up build...
del *.bwn

echo Done!