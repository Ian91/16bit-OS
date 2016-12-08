BITS 16

floppy_bootloader_main:
	MOV BX, 0x07C0		; Set data segment to bootloader's default segment
	MOV DS, BX

	_start:
	MOV BX, welcome_string
	CALL print 
	MOV BX, option_1_string
	CALL print
	MOV BX, option_2_string
	CALL print
	MOV BX, option_3_string
	CALL print 	

	MOV AH, 0x00
	INT 0x16
	MOV AH, 0x0E
	INT 0x10
	CMP AL, 49
	JE choice_run_or_read_sector
	CMP AL, 50
	JE choice_copy_floppy_sector
	CMP AL, 51
	JE choice_show_filesystem
	
	MOV BX, invalid_choice_string
	CALL print
	JMP _start

	choice_run_or_read_sector:
		CALL get_run_program_sector
		JMP 0x200	
	choice_copy_floppy_sector:
		CALL get_program_copy_sector
		JMP 0x200
	choice_show_filesystem:
		CALL get_show_filesystem_sector
		JMP 0x200

	%if 0
				   

	%endif; 0
	
;end floppy_bootloader_main


welcome_string: db 13, 10, "Booted from the hard disk. Welcome to the OS! Choose an action:", 0
option_1_string: db 13, 10, 9, "1) Run a program/read a file (from a known sector)", 0
option_2_string: db 13, 10, 9, "2) Copy a sector from floppy to disk", 0
option_3_string: db 13, 10, 9, "3) Show filesystem", 13, 10, 9, 0
invalid_choice_string: db 13, 10, "Invalid choice.", 0
prog_copy_mesg: db 13, 10, "Successfully loaded the program copying program into memory.", 0

print:
	PUSHA
	MOV AH, 0x0E
	print_loop:
		MOV AL, BYTE [BX]
		INT 0x10
		INC BX
		CMP BYTE [BX], 0
		JNE print_loop
	POPA
	RET 	

get_run_program_sector:
	PUSHA
	MOV AH, 0x02		   ; BIOS int13h "read sector" function
	MOV AL, 1		   ; Number of sectors to read
	MOV CL, 2		   ; "run program" program is always located on sector 2 of HDD
	MOV CH, 0		   ; Cylinder/track
	MOV DH, 0		   ; Head
	MOV DL, 0x80		   ; Disk number (here, the hard disk)
	MOV BX, 0x07C0		   ; Segment containing the destination buffer
	MOV ES, BX
	MOV BX, 0x200		   ; Destination buffer offset (will jump here)
	INT 0x13
	POPA
	RET

get_program_copy_sector:
	PUSHA
	MOV AH, 0x02		   ; BIOS int13h "read sector" function
	MOV AL, 1		   ; Number of sectors to read
	MOV CL, 3		   ; "sector copy" program is always located on sector 3 of HDD
	MOV CH, 0		   ; Cylinder/track
	MOV DH, 0		   ; Head
	MOV DL, 0x80		   ; Disk number (here, the hard disk)
	MOV BX, 0x07C0		   ; Segment containing the destination buffer
	MOV ES, BX
	MOV BX, 0x200		   ; Destination buffer offset (will jump here)
	INT 0x13
	POPA
	RET

get_show_filesystem_sector:	
	PUSHA
	MOV AH, 0x02		   ; BIOS int13h "read sector" function
	MOV AL, 1		   ; Number of sectors to read
	MOV CL, 4		   ; "show filesystem" program is always located on sector 4 of HDD
	MOV CH, 0		   ; Cylinder/track
	MOV DH, 0		   ; Head
	MOV DL, 0x80		   ; Disk number (here, the hard disk)
	MOV BX, 0x07C0		   ; Segment containing the destination buffer
	MOV ES, BX
	MOV BX, 0x200		   ; Destination buffer offset (will jump here)
	INT 0x13
	POPA
	RET
	

times 510-($-$$) db 0		; Pad rest of sector and add bootloader signature
dw 0xAA55
