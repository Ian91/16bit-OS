BITS 16
ORG 0x07C00
	
main:	
	CLI				; clear interrupts
	XOR AX, AX			; null segments
	MOV DS, AX
        MOV ES, AX
        MOV AX, 0x9000		; stack begins at 0x9000-0xffff
	MOV SS, AX
	MOV SP, 0xFFFF
	STI				; enable interrupts
	MOV BX, stack_mesg
	CALL print

	CALL installGdt

	MOV BX, entering_protected_mode_mesg
	CALL print
	CLI
	MOV EAX, CR0
	OR EAX, 1
	MOV CR0, EAX
	JMP 0x08:protected_mode


stack_mesg: DB 13, 10, "Set up the stack.", 0
gdt_mesg: DB 13, 10, "Loaded GDT.", 0
entering_protected_mode_mesg: DB 13, 10, "Entering protected mode.", 0
print:
	PUSHA
	MOV AH, 0x0E
	print_loop:
		MOV BYTE AL, [BX]
		INT 0x10
		INC BX
		CMP BYTE [BX], 0
		JNE print_loop
	POPA
	RET 

installGdt:
	CLI			; make sure to clear interrupts first!
	PUSHA
	LGDT [toc]		; load GDT into GDTR
	STI
	POPA
	MOV BX, gdt_mesg
	CALL print
	RET

print_32:
	MOV EAX, 5
	RET

BITS 32
protected_mode:
	MOV		AX, 0x10		; set data segments to data selector (0x10)
	MOV		DS, AX
	MOV		SS, AX
	MOV		ES, AX
	MOV		ESP, 90000h		; stack begins from 90000h

	MOV EAX, 14
	
	JMP $


BITS 16
; Offset 0 in GDT: Descriptor code=0
gdt_data: 
	DD 0 				; null descriptor
	DD 0 
 
; Offset 0x8 bytes from start of GDT: Descriptor code therefore is 0x08
 
; gdt code:				; code descriptor
	DW 0x0FFFF 			; limit low
	DW 0 				; base low
	DB 0 				; base middle
	DB 10011010B 			; access
	DB 11001111B 			; granularity
	DB 0 				; base high
 
; Offset 16 bytes (0x10) from start of GDT. Descriptor code therfore is 0x10.
 
; gdt data:				; data descriptor
	DW 0x0FFFF 			; limit low (Same as code)
	DW 0 				; base low
	DB 0 				; base middle
	DB 10010010B 			; access
	DB 11001111B 			; granularity
	DB 0				; base high
 
;...Other descriptors begin at offset 0x18. Remember that each descriptor is 8 bytes in size?
; Add other descriptors for Ring 3 applications, stack, whatever here...
 
end_of_gdt:
toc: 
	DW end_of_gdt - gdt_data - 1 	; limit (Size of GDT)
	DD gdt_data 			; base of GDT



	

times 510-($-$$) DB 17		; Pad rest of sector
DW 0xAA55
