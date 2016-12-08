nasm -f bin floppy_boot.asm -o floppy_boot.bin 
nasm -f bin hd_boot.asm -o hd_boot.bin
nasm -f bin run_program_program.asm -o run_program_program.bin
nasm -f bin sector_copy_program.asm -o sector_copy_program.bin
nasm -f bin show_filesystem_program.asm -o show_filesystem_program.bin

dd if=floppy_boot.bin of=os.flp bs=512 count=1 &> /dev/null
dd if=hd_boot.bin of=os.flp bs=512 count=1 oflag=append conv=notrunc &> /dev/null
dd if=run_program_program.bin of=os.flp bs=512 count=1 oflag=append conv=notrunc &> /dev/null
dd if=sector_copy_program.bin of=os.flp bs=512 count=1 oflag=append conv=notrunc &> /dev/null
dd if=show_filesystem_program.bin of=os.flp bs=512 count=1 oflag=append conv=notrunc &> /dev/null

qemu-system-i386 -fda os.flp -hda test.dr -soundhw pcspk -monitor stdio
