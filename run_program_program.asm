BITS 16
ORG 0x200

run_program_floppy_sector:
	cli				; clear interrupts
	xor	ax, ax			; null segments
        mov	ds, ax
        mov	es, ax
       ; mov	ax, 0x9000		; stack begins at 0x9000-0xffff
	;mov	ss, ax
	;mov	sp, 0xFFFF
	sti				; enable interrupts
	MOV BX, stack_mesg
	CALL print

	cli			; make sure to clear interrupts first!
	lgdt	[toc]		; load GDT into GDTR
	sti
	MOV BX, gdt_mesg
	CALL print
	JMP $

	CLI
	MOV EAX, CR0
	OR EAX, 1
	MOV CR0, EAX
	JMP 0x08:protected_mode

stack_mesg: db 13, 10, "Set up the stack.", 0
gdt_mesg: db 13, 10, "Loaded GDT.", 0
protected_mode_mesg: db 13, 10, "Entering protected mode.", 0
print:
	;PUSHA
	MOV AH, 0x0E
	print_loop:
		MOV BYTE AL, [BX]
		INT 0x10
		INC BX
		CMP BYTE [BX], 0
		JNE print_loop
	;POPA
	RET 

print_32:
	MOV EAX, 5
	RET

BITS 32
protected_mode:
	;mov		ax, 0x10		; set data segments to data selector (0x10)
	;mov		ds, ax
	;mov		ss, ax
	;mov		es, ax
	;mov		esp, 90000h		; stack begins from 90000h

	MOV EAX, 11
	
	JMP $


BITS 16
db 0
; Offset 0 in GDT: Descriptor code=0
gdt_data: 
	dd 0 				; null descriptor
	dd 0 
 
; Offset 0x8 bytes from start of GDT: Descriptor code therfore is 8
 
; gdt code:				; code descriptor
	dw 0FFFFh 			; limit low
	dw 0 				; base low
	db 0 				; base middle
	db 10011010b 			; access
	db 11001111b 			; granularity
	db 0 				; base high
 
; Offset 16 bytes (0x10) from start of GDT. Descriptor code therfore is 0x10.
 
; gdt data:				; data descriptor
	dw 0FFFFh 			; limit low (Same as code)
	dw 0 				; base low
	db 0 				; base middle
	db 10010010b 			; access
	db 11001111b 			; granularity
	db 0				; base high
 
;...Other descriptors begin at offset 0x18. Remember that each descriptor is 8 bytes in size?
; Add other descriptors for Ring 3 applications, stack, whatever here...
 
end_of_gdt:
toc: 
	dw end_of_gdt - gdt_data - 1 	; limit (Size of GDT)
	dd gdt_data 			; base of GDT



	

times 512-($-$$) DB 17		; Pad rest of sector
