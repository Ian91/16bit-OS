nasm -f bin floppy_boot.asm -o floppy_boot.bin
nasm -f bin hd_boot.asm -o hd_boot.bin
nasm -f bin assembler.asm -o assembler.bin
dd if=floppy_boot.bin of=os.flp bs=512 count=1
dd if=hd_boot.bin of=os.flp bs=512 count=1 oflag=append conv=notrunc
dd if=assembler.bin of=os.flp bs=512 count=1 oflag=append conv=notrunc
qemu-system-i386 -fda os.flp -hda test.dr -monitor stdio
