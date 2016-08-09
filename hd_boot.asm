BITS 16

hd_bootloader_main:
	mov bx, 0x07C0		; Set data segment to bootloader's default segment
	mov ds, bx

	mov bx, welcome_string		; Print "welcome" message
	mov ah, 0x0E
	print_welcome_loop:
		mov al, byte [bx]
		int 0x10
		inc bx
		cmp byte [bx], 0
		jne print_welcome_loop
	;end print_welcome_loop

	mov al, 13			; Print CR/LF
	int 0x10	
	mov al, 10
	int 0x10

	mov bx, prompt_string		; Prompt user to enter program drive and sector
	mov ah, 0x0E
	print_prompt_loop:
		mov al, byte [bx]
		int 0x10
		inc bx
		cmp byte [bx], 0
		jne print_prompt_loop
	;end print_prompt_loop

	mov ah, 0x00		   ; Get floppy sector from which to read program
	int 0x16		   ;    (goes into cl parameter)
	mov ah, 0x0E
	int 0x10		   ; Tell user what they entered
	cmp byte al, 'F'
	je load_floppy_program
	cmp byte al, 'H'
	je load_hd_program
	jmp $		           ; Else, crash OS	


   load_floppy_program:

	mov ah, 0x00		   ; Get floppy sector from which to read program
	int 0x16		   ;    (goes into cl parameter)
	mov ah, 0x0E
	int 0x10		   ; Tell user what they entered
	mov cl, al
	sub cl, 48
	
				   ; Read program from floppy disk
	mov ah, 0x02		   ; BIOS int13h "read sector" function
	mov al, 1		   ; Number of sectors to read
	mov ch, 0		   ; Cylinder/track
	mov dh, 0		   ; Head
	mov dl, 0		   ; Disk number (here, the floppy disk)
	mov bx, 0x07C0		   ; Segment containing the destination buffer
	mov es, bx
	mov bx, 0x200		   ; Destination buffer offset
	int 0x13

	jmp 0x200		   ; Jump to program
   ;end load_floppy_program


   load_hd_program:

	mov ah, 0x00		   ; Get hard drive sector from which to read program
	int 0x16		   ;    (goes into cl parameter)
	mov ah, 0x0E
	int 0x10		   ; Tell user what they entered
	mov cl, al
	sub cl, 48
				   ; Read program from hard disk
	mov ah, 0x02		   ; BIOS int13h "read sector" function
	mov al, 1		   ; Number of sectors to read
	mov ch, 0		   ; Cylinder/track
	mov dh, 0		   ; Head
	mov dl, 0x80		   ; Disk number (here, the hard disk)
	mov bx, 0x07C0		   ; Segment containing the destination buffer
	mov es, bx
	mov bx, 0x200		   ; Destination buffer offset
	int 0x13

	jmp 0x200		   ; Jump to program

;end hd_bootloader_main


welcome_string: db 13, 10, 13, 10, "Welcome to the OS.", 0
prompt_string: db 13, 10, "Select a disk (F/H) from which to run a program", 13, 10, "   (F, sector 3 to 'assemble' to HD): ", 0

times 510-($-$$) db 0		; Pad rest of sector and add bootloader signature
dw 0xAA55
