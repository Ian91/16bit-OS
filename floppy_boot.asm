BITS 16

hd_bootloader_main:
	mov bx, 0x07C0		; Set data segment to bootloader's default segment
	mov ds, bx


				   ; Read hard drive bootloader from floppy disk
	mov ah, 0x02		   ; BIOS int13h "read sector" function
	mov al, 1		   ; Number of sectors to read
	mov ch, 0		   ; Cylinder/track
	mov cl, 2		   ; Sector number to read (hard drive bootloader is on sector 2)
	mov dh, 0		   ; Head
	mov dl, 0		   ; Disk number (here, the floppy disk)
	mov bx, 0x07C0		   ; Segment containing the destination buffer
	mov es, bx
	mov bx, 0x200		   ; Destination buffer offset
	int 0x13

				   ; Write hard drive bootloader to hard disk
	mov ah, 0x03		   ; BIOS int13h "write sector" function
	mov al, 1		   ; Number of sectors to write
	mov ch, 0		   ; Cylinder/track
	mov cl, 1		   ; Sector number to write (hard drive bootloader must go in sector 1)
	mov dh, 0		   ; Head
	mov dl, 0x80		   ; Disk number (here, the hard disk)
	mov bx, 0x07C0		   ; Segment containing the source buffer
	mov es, bx
	mov bx, 0x200		   ; Source buffer offset
	int 0x13

	mov bx, welcome_string		; Print "welcome" message
	mov ah, 0x0E
	print_welcome_loop:
		mov al, byte [bx]
		int 0x10
		inc bx
		cmp byte [bx], 0
		jne print_welcome_loop
	;end print_welcome_loop
	
;end hd_bootloader_main


welcome_string: db 13, 10, 13, 10, "Welcome to the floppy installer. The OS bootloader is now", 13, 10, "   installed on sector 1 of the hard disk. Restart now.", 0

times 510-($-$$) db 0		; Pad rest of sector and add bootloader signature
dw 0xAA55
