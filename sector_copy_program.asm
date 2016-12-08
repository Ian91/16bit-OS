BITS 16
ORG 0x200

program_copy_floppy_sector:
	MOV BX, copy_program_welcome_string
	CALL print
	JMP 0


copy_program_welcome_string: db 13, 10, "Welcome to the sector copying program. Choose a floppy sector to copy:", 0

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

get_floppy_sector:
	PUSHA
	MOV AH, 0x02		   ; BIOS int13h "read sector" function
	MOV AL, 1		   ; Number of sectors to read
	MOV CH, 0		   ; Cylinder/track
	MOV DH, 0		   ; Head
	MOV DL, 0		   ; Disk number (here, the floppy disk)
	MOV BX, 0x07C0		   ; Segment containing the destination buffer
	MOV ES, BX
	MOV BX, 0x200		   ; Destination buffer offset
	INT 0x13
	POPA
	RET

write_hd_sector:
	PUSHA
	MOV AH, 0x03		   ; BIOS int13h "write sector" function
	MOV AL, 1		   ; Number of sectors to write
	MOV CH, 0		   ; Cylinder/track
	MOV DH, 0		   ; Head
	MOV DL, 0x80		   ; Disk number (here, the hard disk)
	MOV BX, 0x07C0		   ; Segment containing the source buffer
	MOV ES, BX
	MOV BX, 0x400		   ; Source buffer offset
	INT 0x13

	JNC write_hd_sector_done
		JMP $

	write_hd_sector_done:
	POPA
	RET

test_empty_sector:
	MOV DX, 1
	test_empty_sector_loop:
		CMP BYTE [BX], 0
		JNE sector_not_empty
		INC DX				; checked a byte, so increment byte counter
		CMP DX, 512
		JE sector_is_empty
		INC BX
		JMP test_empty_sector_loop

	sector_not_empty:
		MOV AL, 0
		RET

	sector_is_empty:
		MOV AL, 1
		RET

get_first_empty_hd_sector:			; WARNING: THIS MAY RETURN AN INCORRECT RESULT WITHOUT ERROR CHECKING OF GET_HD_SECTOR ITSELF
	MOV CL, 1
	test_first_empty_hd_sector_loop:
		;CALL get_hd_sector
		MOV BX, 0x200
		CALL test_empty_sector
		CMP AL, 0
		JNE empty_hd_sector_found
		INC CL
		JMP test_first_empty_hd_sector_loop

	empty_hd_sector_found:
		MOV AL, CL		; Put the sector number in AL, as return value
		RET			
	


	

times 512-($-$$) db 17		; Pad rest of sector
