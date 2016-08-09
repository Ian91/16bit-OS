# This script assumes that the hard drive "test.dr" already exists
#   If it doesn't, run:
#		qemu-img create test.dr 128M


nasm -f bin floppy_boot.asm -o floppy_boot.bin
nasm -f bin hd_boot.asm -o hd_boot.bin
nasm -f bin assembler.asm -o assembler.bin
dd if=floppy_boot.bin of=os.flp bs=512 count=1
dd if=hd_boot.bin of=os.flp bs=512 count=1 oflag=append conv=notrunc
dd if=assembler.bin of=os.flp bs=512 count=1 oflag=append conv=notrunc
qemu-system-i386 -fda os.flp -hda test.dr -monitor stdio
