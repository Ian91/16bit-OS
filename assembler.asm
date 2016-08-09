; "Assembler" that accepts a sequence of lowercase hex bytes and writes them 
;    to sector 5 of hard disk

BITS 16
ORG 0x200		; Assume that this code will be located 512 bytes after start of bootloader (in RAM)

main:

	mov ah, 0x0E		; Print CRLF
	mov al, 13
	int 0x10
	mov al, 10
	int 0x10

	mov ah, 0x00		; Get HD sector to which we write the program
	int 0x16
	sub al, 48
	mov byte [sector_choice], al

	mov ah, 0x0E		; Print CRLF
	mov al, 13
	int 0x10
	mov al, 10
	int 0x10

	mov bx, prog_buffer			; Pointer to memory that will be written
	assemble_loop:
		mov dl, 0			; Byte accumulator
		input_loop:
			call getNibble		; Returns result in cl
			cmp cl, 40		; If user entered 'X'
			je end_assemble_loop
			xor ax, ax
			mov al, cl
			mov ch, 16
			mul ch
			mov dl, al

			call getNibble
			cmp cl, 40
			je end_assemble_loop
			mov al, cl
			add dl, al
		end_input_loop:
		mov byte [bx], dl
		inc bx
		
		mov ah, 0x0E
		mov al, 13
		int 0x10
		mov al, 10
		int 0x10
		jmp assemble_loop
	end_assemble_loop:

	mov ah, 0x03			; Write bytes to disk
	mov al, 1
	mov byte cl, [sector_choice]	; HD sector number
	mov ch, 0
	mov dh, 0
	mov dl, 0x80
	mov bx, 0x07C0
	mov es, bx
	mov bx, prog_buffer
	int 0x13

	jmp 0x0000			; Jump back to main OS loop

;end main
		


getNibble:
	mov ah, 0x00
	int 0x16
	mov cl, al

	cmp cl, 'a'
	je hex_10
	cmp cl, 'b'
	je hex_11
	cmp cl, 'c'
	je hex_12
	cmp cl, 'd'
	je hex_13
	cmp cl, 'e'
	je hex_14
	cmp cl, 'f'
	je hex_15
	jmp default_get_nibble		; If character not in {a, ..., f}, don't change al

	
	hex_10:
		mov cl, 0x0A
		mov ah, 0x0E
		mov al, 'a'
		int 0x10
		ret
	hex_11:
		mov cl, 0x0B
		mov ah, 0x0E
		mov al, 'b'
		int 0x10
		ret
	hex_12:
		mov cl, 0x0C
		mov ah, 0x0E
		mov al, 'c'
		int 0x10
		ret
	hex_13:
		mov cl, 0x0D
		mov ah, 0x0E
		mov al, 'd'
		int 0x10
		ret
	hex_14:
		mov cl, 0x0E
		mov ah, 0x0E
		mov al, 'e'
		int 0x10
		ret
	hex_15:
		mov cl, 0x0F
		mov ah, 0x0E
		mov al, 'f'
		int 0x10
		ret

	default_get_nibble:
		mov ah, 0x0E
		mov al, cl
		int 0x10
		sub cl, 48
		ret
;end getNibble




prog_buffer: times 300 db 17			; 17 is just for convenience for viewing in hex editor (as opposed to 00)
sector_choice: db 00




