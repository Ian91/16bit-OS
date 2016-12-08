BITS 16
ORG 0x200

show_filesystem_floppy_sector:
	MOV BX, show_filesystem_welcome_string
	CALL print
	JMP 0


show_filesystem_welcome_string: db 13, 10, "FILESYSTEM WILL BE SHOWN HERE", 0
			
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

	
times 512-($-$$) db 17		; Pad rest of sector
