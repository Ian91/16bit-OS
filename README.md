# 16bit-OS
This OS runs in 16-bit real mode. I've been testing it on QEmu with the i386 VM (see the "go" file, which is a simple build and run script).

The stack segment still needs to be set up before any pushing or popping can be added.

HOW IT WORKS:
	1. The script assembles the three source files into "raw binary" format (no PE or ELF executable metadata).
	2. The script writes floppy_boot.bin, hd_boot.bin, and assembler.bin to sectors 1, 2, and 3 (respectively) of a virtualized floppy disk.
	3. The script starts up a virtual machine with an i386 processor and 128 MB of RAM (the default).
		The machine is given a floppy drive and a 128 MB hard drive.
	4. The machine boots from the floppy, because the first sector of the floppy (i.e. floppy_boot.bin) contains the boot signature.
	5. floppy_boot.bin installs a bootloader onto the hard disk (i.e. hd_boot.bin) and tells the user to exit.
		(The VM halts and the user has to force close it.)
	6. When the VM is restarted with the same floppy and hard drive, it now boots from the hard drive, and the user is prompted to
		enter a hard drive or floppy drive sector from which a program will be loaded and executed.
	7. The user can, for example, enter "F3" to load the "assembler" program from sector 3 of the floppy. They can then enter bytes that
		are written to sector 5 of the hard drive. On reboot, the user can type "H5" to execute these bytes.
