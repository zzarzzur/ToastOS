[org 0x7C00]

main:
	mov ax, 0x0000
	mov ds, ax
	
	mov si, welcome
	call puts
	mov si, info
	call puts
	
	.main_loop:
		mov si, prompt
		call puts
		
		mov di, buffer
		call gets
		
		mov si, buffer
		cmp byte [si], 0
		je .main_loop
		
		mov si, buffer
		mov di, cmd_help
		call strcmp
		jc .help
		
		mov si, buffer
		mov di, cmd_cool
		call strcmp
		jc .cool
		
		mov si, buffer
		mov di, cmd_version
		call strcmp
		jc .version
		
		mov si, buffer
		call puts
		mov si, invalidCmd
		call puts
		jmp .main_loop
		
		.help:
			mov si, msg_help
			call puts
			jmp .main_loop
		
		.cool:
			mov si, msg_cool
			call puts
			jmp .main_loop
		
		.version:
			mov si, msg_version
			call puts
			jmp .main_loop
		

puts:
	mov ah, 0x0E
	mov bh, 0x00
	mov bl, 0x07
	
	.nextChar:
		lodsb
		or al, al
	
		jz .return
	
		int 0x10
		jmp .nextChar
	
	.return:
		ret
		
gets:
	xor cl, cl
	
	.loop:
		mov ah, 0
		int 0x16
		
		cmp al, 0x08
		je .backspace
		
		cmp al, 0x0D
		je .enter
		
		cmp cl, 0x3F
		je .loop
		
		mov ah, 0x0E
		int 0x10
		
		stosb
		inc cl
		jmp .loop
		
		.backspace:
			cmp cl, 0
			je .loop
			
			dec di
			mov byte [di], 0
			dec cl
			
			mov ah, 0x0E
			mov al, 0x08
			int 0x10
			
			mov al, ' '
			int 0x10
			
			mov al, 0x08
			int 0x10
			
			jmp .loop
			
		.enter:
			mov al, 0
			stosb
			
			mov ah, 0x0E
			mov al, 0x0D
			int 0x10
			mov al, 0x0A
			int 0x10
			
			ret

strcmp:
	.loop:
		mov al, [si]
		mov bl, [di]
		cmp al, bl
		jne .notequal
		
		cmp al, 0
		je .done
		
		inc di
		inc si
		jmp .loop
		
		.notequal:
			clc
			ret
			
		.done:
			stc
			ret

prompt db "ToastOS:~$ ", 0
welcome db "Welcome to ToastOS", 13, 10, 0
info db "For help type hlp", 13, 10, 0
invalidCmd db ": Invalid Command", 13, 10, 0
cmd_help db "hlp", 0
msg_help db "Commands: hlp, cool, version", 13, 10, 0
cmd_cool db "cool", 0
msg_cool db "Joel is cool", 13, 10, 0
cmd_version db "version", 0
msg_version db  "Name: ToastOS", 13, 10, "Author: Joel Moore", 13, 10, "License: GPLv3", 13, 10, "Version: 0.1", 13, 10, 0
buffer times 64 db 0

times 510-($-$$) db 0
dw 0xAA55
